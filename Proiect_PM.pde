import processing.serial.*;
Serial port;

int window_length = 1000;
int window_height = 1000 / 2;
int max_x = 9 * window_length / 10; // the max ox coord
int max_y = 9 * window_height / 10; // the max oy coord
int center_x = window_length / 2;
int center_y = window_height; // we put window_height because the Y = 0 is the top of the screen in translate
int line_length = 90 * window_length / (100 * 2); // the length of the radar lines
int angle = 0;
int last_angle = -1;
int last_distance = -1;
int last_text_display = 10;
ArrayList<Point> objects; // array where we put the identified objects


// class which describes a Point on the graph
class Point {
  int angle;
  int distance;
  int time;
  
  public Point(int angle, int distance) {
    this.angle = angle;
    this.distance = distance;
    this.time = 100;
  }
  
  public void fade() {
    this.time--;
  }
}

// Draws the radar
void drawRadar() {
  pushMatrix(); // save the coord matrix on the stack
  int center_x = window_length / 2;
  int center_y = window_height;
  translate(center_x, center_y); // moves the starting coordinats to new location
  strokeWeight(3); // the width of the lines
  stroke(0, 255, 0); // set the color 
  // draws the arc lines
  // we put the * 2 on window height, because the height is lower than the length
  arc(0, 0, 9 * window_length / 10, 9 * 2 * window_height / 10, PI, TWO_PI);
  arc(0, 0, 7 * window_length / 10, 7 * 2 * window_height / 10, PI, TWO_PI);
  arc(0, 0, 5 * window_length / 10, 5 * 2 * window_height / 10, PI, TWO_PI);
  arc(0, 0, 3 * window_length / 10, 3 * 2 * window_height / 10, PI, TWO_PI);
  // draws the angle lines
  line(-line_length, 0, line_length, 0);
  line(0, 0, -line_length*cos(radians(30)), -line_length*sin(radians(30)));
  line(0, 0, -line_length*cos(radians(60)), -line_length*sin(radians(60)));
  line(0, 0, -line_length*cos(radians(90)), -line_length*sin(radians(90)));
  line(0, 0, -line_length*cos(radians(120)), -line_length*sin(radians(120)));
  line(0, 0, -line_length*cos(radians(150)), -line_length*sin(radians(150)));
  line(-line_length*cos(radians(30)), 0, line_length, 0);
  popMatrix(); // restore the coord matrix
}

void drawDetectionLine(int angle) {
  pushMatrix();
  translate(center_x, center_y); 
  strokeWeight(2); // the width of the lines
  stroke(0, 255, 0); // set the color
  line(0, 0, line_length * cos(radians(angle)), -line_length * sin(radians(angle)));
  popMatrix();
}

void drawObject(int angle, int distance) {
  pushMatrix();
  translate(center_x, center_y);   
  strokeWeight(15); // the width of the lines
  stroke(255, 0, 0); // set the color  
  int point_distance = distance * line_length / 40;
  point(point_distance * cos(radians(angle)), -point_distance * sin(radians(angle)));
  popMatrix();
}

void drawObjects(ArrayList<Point> objects) {
  ArrayList<Point> filteredPoints = new ArrayList<Point>();
  for (Point p : objects) {
    drawObject(p.angle, p.distance);
    p.fade();
    if (p.time > 0)
      filteredPoints.add(p);
  }
  int i = 0;
  while (i < objects.size()) {
     if(objects.get(i).time > 0)
       i++;
     else {
       objects.remove(i);
     }
  }
}

void drawText(int angle, int distance) {
  String angleStr = "";
  String distStr = "";
  if (distance <= 40 && distance > 0) {
    angleStr = angle + "°";
    distStr = distance + "cm";
  }
  pushMatrix();
  fill(0, 5000);
  translate(window_length * 2 / 10, window_height * 11 / 10);
  textSize(32);
  fill(0, 255, 0);
  text("Distance: " + distStr, 0, 0);
  popMatrix();
  pushMatrix();
  translate(window_length * 6 / 10, window_height * 11 / 10);
  text("Angle: " + angleStr, 0, 0);
  popMatrix();
  pushMatrix();
  translate(window_length * 0.35, window_height * 1.17);
  text("© Lucian Iliescu", 0, 0);
  popMatrix();
}

void settings() {
  smooth();
  size(window_length, window_height * 12/10);
  objects = new ArrayList<Point>();
  //UNCOMMENT WHEN ARDUINO IS PLUGGED IN
  port = new Serial(this,"/dev/ttyUSB0",9600);
  
}

int stop = 40;

void draw() {
  
  //background(51);
  fill(0,  15);
  rect(-10, -10, window_length * 2, window_height * 3); // Set the background black
  drawRadar();
  if (last_angle >= 0) {
    drawText(last_angle, last_distance);
  }
  //UNCOMMENT WHEN ARDUINO IS PLUGGED IN
  if(port.available() > 0) {
    String info = port.readStringUntil('\n');
    if (info != null) {
        String[] data = split(info, '|');    
        if (data.length == 2) {
          String degreeStr = data[0].replaceAll("\\D+","");
          int degree = Integer.valueOf(degreeStr);
          drawDetectionLine(degree);
          String distanceStr = data[1].replaceAll("\\D+","");
          int distance = Integer.valueOf(distanceStr);
          if (distance <= 40) {
            last_angle = degree;
            last_distance = distance;
            objects.add(new Point(degree, distance));
        }
      }
    }
  }
  drawObjects(objects);
  angle = (angle + 1) % 179;
}

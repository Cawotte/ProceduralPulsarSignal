
final int lines     = 40;
final int segments  = 80;

// A12 Phone Size ratio
// Those are here because it's originally a project to print a custom phone case design
final float phoneRatio = 164. / 75.8;
final float minHeightToAvoidCamera = 45. / 164.; // How much to offset the drawing so it doesn't overlap the camera

// Colors constants
final color BLACK          = color(0);
final color WHITE          = color(255);
final color DARK_GRAY     = color(70);
final color MID_GRAY     = color(150); 
final color LIGHT_GRAY     = color(220); 

// Thanks to https://coolors.co/generate for most of those colors
final color LAVENDER     = color(238, 229, 233, 255);
final color AZURE     = color(242, 253, 255);
final color GOLDENROD     = color(218, 165, 32); //gold
final color LIVER     = color(95, 72, 66); //brown
final color DARK_PURPLE     = color(36, 22, 35);
final color BYZANTIUM     = color(127, 5, 95);

// Shades of Red
final color VERMILLION     = color(188, 19, 94, 255);
final color DARK_VERMILLION     = color(88, 9, 44, 255);

final color BLACK_CORAL     = color(65, 84, 99);

// Shades of Blue
final color MIDDLE_BLUE     = color(194, 234, 240, 255);
final color OXFORD_BLUE     = color(9, 22, 37);
final color BEAU_BLUE       = color(184, 208, 235);
final color CELESTE         = color(173, 252, 249);
final color BOY_BLUE        = color(128, 164, 237);
final color BABY_BLUE       = color(159, 188, 237);
final color PRUSSIAN_BLUE   = color(24, 40, 58);
final color DARK_ELECTRIC_BLUE = color(92, 111, 131);
final color CADET_GREY       = color(136, 156, 180);

// Mint green
final color OPAL     = color(146, 182, 177);
final color TEAL     = color(36, 123, 123);
final color MINT     = color(163, 247, 181);

final int OPAQUE = 255;

// Used colors
final boolean noBackgroundGradient = false;

final color backgroundColor       = OXFORD_BLUE;
final color topBackgroundColor    = PRUSSIAN_BLUE;

// Circular Suns
final color sunFillColor     = LAVENDER;
final color sunStrokeColor   = OXFORD_BLUE;
final int sunFillOpacity     = 255;
final int sunStrokeOpacity   = 255;
final int sunStrokeWeight    = 3;
final boolean secondSunColorAreRevert = true;

// Lines
final boolean noLineStrokes = false;

final float strokeWeight   = 2;
final color strokeColor    = VERMILLION;
final int strokeOpacity    = 2550; // 0 - 255
final int lineSmooth       = 2;

final boolean hasRandomLine = false; // Only draw a certain random % of lines.
final int randomLinePercent = 60;   // Chances to draw a line. whole %

// Autoscroll
final boolean autoscroll = false;
final float scrollPerFrame = 0.006;

// Pattern
// How high and low the noises value are converted into pixel distance
final float lowestNoise = -50;
final float highestNoise = 300;

// Can restrict drawing in a sub-rectangle of the screen, using percents.
final float minWidthPercent  = 0.15;
final float maxWidthPercent  = 0.85;
final float minHeightPercent = minHeightToAvoidCamera + 0.04;
final float maxHeightPercent = 0.84;

float minWidth, maxWidth, minHeight, maxHeight;

NoiseData noiseData;

void setup() {
  size(640, 1380);
  
  smooth( lineSmooth );
  
  if ( !autoscroll )
    noLoop();
  
  minWidth = width * minWidthPercent;
  maxWidth = width * maxWidthPercent;
  minHeight = height * minHeightPercent;
  maxHeight = height * maxHeightPercent;
  
  // Care for the size of the rectangle we are drawing the lines on, to know on which ratio to scale the noise sampling to not stretch it.
  float noiseMapRatio =  ( maxHeight - minHeight ) / ( maxWidth - minWidth );
  
  noiseData = new NoiseData( lines, segments, noiseMapRatio );
} 

void draw() {
   
  if ( autoscroll )
  {
    noiseData.offsetY -= scrollPerFrame;
    noiseData.UpdateNoiseData(); 
  }
  
  background( backgroundColor, OPAQUE );
  
  drawSuns();
  drawLines( lines );
  //<>//
}

void keyPressed()
{
  //Save
  if ( key == 's' ) //<>//
  {
    int uniqueID = (int)random(10000); // Don't guarantee to be unique, but close enough to not overwrite existing saved images.
    String fileName = "GeneratedImages/GeneratedLines_" + uniqueID + ".png";
    
    save( fileName );
  }
}

// Change the seed of the noise to generate a new randomized map.
void mousePressed() {
  noiseData.SetSeed( mouseY ); //<>//
  noiseData.UpdateNoiseData();
  redraw();
  save( "last_generated_lines.png" );
}

float scrollAmount = 0.04;

// Change the offset of the noise data to scroll the noise map, doesn't re-randomize it.
void mouseWheel(MouseEvent event) {
  float wheelDirection = event.getCount();
  
  noiseData.offsetY += wheelDirection * scrollAmount; //Can change to offsetX for horizontal scroll.
  noiseData.UpdateNoiseData();
  redraw();
}


// Position is [0, 1], percent of screens. Mostly hardcoded.
void drawSuns()
{
  stroke( sunStrokeColor, sunStrokeOpacity );
  fill( sunFillColor, sunFillOpacity );
  strokeWeight( sunStrokeWeight );
  
  // Draw the first sun
  int r = 200;
  float w = 0.65 * width;
  float h = 0.17 * height;
  circle( w, h, r);
  
  drawRandomParallelLinesInsideCircle( w, h, r / 2.02, 4, 15 );
  drawRandomParallelLinesInsideCircle( w, h, r / 2.02, 2, 20 );

  if ( secondSunColorAreRevert )
  {
    stroke( sunFillColor, sunFillOpacity );
    fill( sunStrokeColor, sunStrokeOpacity );
  }
  
  // Second, smaller sun
  r = 80;
  w = w + 50;
  h = h + 75;
  circle( w, h, r);
  drawRandomParallelLinesInsideCircle( w, h, r / 2.02, 2, 8 );
}

void drawRandomLinesInsideCircle( float x, float y, float r, int nbLines, float forcedOffset )
{
  for ( int i = 0; i < nbLines; i++ )
  {
    float angle = random(TWO_PI);
    float x1 = ( r / 2 ) * sin(angle);
    float y1 = ( r / 2 ) * cos(angle);
    
    float offset = random(PI);
    if ( forcedOffset > 0 )
      offset = forcedOffset;
      
    float x2 = ( r / 2 ) * sin(angle + offset);
    float y2 = ( r / 2 ) * cos(angle + offset);
    
    line( x + x1, y + y1, x + x2, y + y2);
  }
}

// This one goes to stackOverflow : https://stackoverflow.com/questions/52390712/drawing-parallel-equidistant-lines-inside-a-circle
void drawRandomParallelLinesInsideCircle( float x, float y, float r, int nbLines, float forcedOffset )
{
  float angle = random( TWO_PI );
    
  float offset = r / nbLines; // If no forced offset, equidistant on a half-circle
  if ( forcedOffset > 0 )
    offset = forcedOffset;
  
  for ( int i = 1; i <= nbLines; i++ )
  {
    //something something pythagoras
    float Y = offset * i - r;
    float X = sqrt(r * r - Y * Y );
    
    //rotating
    float x1 = Y * sin( angle ) + X * cos(angle);
    float y1 = Y * cos( angle ) - X * sin(angle);
    float x2 = Y * sin( angle ) - X * cos(angle);
    float y2 = Y * cos( angle ) + X * sin(angle);
    
    line( x + x1, y + y1, x + x2, y + y2);
  }
}

// Draw the current noise data as a grayscale heightmap, coloring pixels. Mostly for debug.
void drawHeightMap()
{
  float squareSize = min(width, height); //<>//
  float pixelW = squareSize / segments;
  float pixelH = squareSize / lines;
  int pixelSize = (int)min(pixelH, pixelW);
  
  noStroke();
  loadPixels();
  for (int i = 0; i < lines; i++)
  {
    for (int j = 0; j < segments; j++)
    {
      float bright = getNoiseHeightAt( i, j, 0, 255 );
      
      for ( int k = 0; k < pixelSize; k++ )
      {
         for ( int kk = 0; kk < pixelSize; kk++ )
          {
            pixels[(i * pixelSize + k) + ((j * pixelSize + kk) * (int)squareSize )] = color(bright, bright, bright);
          }
      }
      
    }
  }
  updatePixels();
}

// Use the NoiseData to draw all lines on the screen.
void drawLines(int nbLines) {

  for  (int i = 0; i < nbLines; i ++ ) 
  {
    if ( !noBackgroundGradient )
      drawLineBackground( i );
      
    if ( !noLineStrokes )
    {
      if ( hasRandomLine )
      {
        float chanceToDrawLine = random( 100 );
        
        if ( chanceToDrawLine >= randomLinePercent )
          continue; // Skip line
      }
      
       drawLine( i );
    }
  }
  
  drawSideColumns();
}

// There's a bit of buggy artifacts on the end of lines/backgrounds, 
// So we cover them with background-colored rectangles on the sides of the screen.
void drawSideColumns()
{
  fill( backgroundColor, OPAQUE );
  noStroke();
  rect( 0, 0, minWidth + 1, height );
  
  float lastSegmentX = map( segments - 1, 0, segments - 1, minWidth, maxWidth ); 
  rect( lastSegmentX, 0, width, height );
}

// Draw the #th line, using noise data.
void drawLine( int line )
{
  float baseHeight = map( line, 0, lines, minHeight, maxHeight );
  float x = 0, y = 0;

  stroke( strokeColor, strokeOpacity );
  strokeWeight( strokeWeight );
  noFill();
  beginShape();

  for (int i = 0; i < segments; i++)
  {
     x = map( i, 0, segments - 1, minWidth, maxWidth );
     y = baseHeight - getNoiseHeightAt( line, i, lowestNoise, highestNoise ); // Referential Y goes toward bottom, so we substract so high values mean higher from our perspective.
     
     curveVertex( x, y );
     if ( i == 0 || i == segments - 1 ) 
       curveVertex( x, y );
  }
 
  endShape();
}

// Color all space below the #th line, using noise data.
void drawLineBackground( int line )
{
  float baseHeight = map( line, 0, lines, minHeight, maxHeight );
  float x = 0, y = 0;

  fill( getBackgroundColor( line ), 255 );
  noStroke();
  beginShape();
  
  vertex( minWidth, 0 );  
  curveVertex( minWidth, baseHeight );
  for (int i = 0; i < segments; i++)
  {
     x = map( i, 0, segments - 1, minWidth, maxWidth );
     y = baseHeight - getNoiseHeightAt( line, i, lowestNoise, highestNoise );
     
     curveVertex( x, y );
     if ( i == 0 || i == segments - 1 ) 
       curveVertex( x, y );
  }
  
  //Close the shape with background that cover all previous lines that would have overlapped below.
  vertex( x, height );
  vertex( minWidth, height );
  vertex( minWidth, 0 );
  endShape();
}

float getNoiseHeightAt( int line, int segment, float minNoise, float maxNoise ) 
{
  return noiseData.GetNoise( line, segment, minNoise, maxNoise );
}

// Lerp a color for the background, from chosen top to actual background color
// Using the lines number
color getBackgroundColor( int line )
{
  float inter = map( line, 0, lines - 1, 0, 1 ); // -1 because lines covers [0, max[
  color lerpedColor = lerpColor( topBackgroundColor, backgroundColor, inter );
  
  return lerpedColor;
}

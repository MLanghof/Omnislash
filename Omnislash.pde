final float BAT = 1.6;
final float FRONTSWING = 0.33;
final int IAS_COUNT = 400+80 + 1;

final int LEVEL = 3;
final int[] SLASHES = { 3, 6, 9, 12 };
final int MAX_SLASHES = SLASHES[LEVEL];
final int MAX_HITS = round(MAX_SLASHES * 1.1) + 2; // Empirical approximation, seems to hold fine for the considered cases.

int[][] results;

// Screw allcaps constants, I'm hungry and don't want to go through renaming all this. Forgive me.
final int incrementIAS = 1; // 1 pixel per IAS regardless...
final int ticksIAS = 20;
final float hitScaling = 20;

int startMillis;

void setup()
{
  size(530, round(hitScaling * MAX_HITS + 70));
  
  startMillis = millis();
  
  results = new int[IAS_COUNT][MAX_HITS];
  for (int i = 0; i < IAS_COUNT; i++)
  {
    results[i] = new int[MAX_HITS];
  }
}

int simsPerFrame = 1000;
int simCount = 0;

void draw()
{  
  for (int i = 0; i < simsPerFrame; i++)
  {
    // Simulate all IAS values every time.
    for (int j = 0; j < IAS_COUNT; j += incrementIAS)
    {
      int hits = SimulateOnce(j - 80);
      assert(hits < MAX_HITS);
      results[j][hits]++;
    }
    simCount++;
  }
  
  // General setup stuff for drawing
  background(255);
  pushMatrix();
  translate(0, height);
  translate(25, -25);
  translate(80, 0);
  
  // Draw grid
  stroke(color(200));
  // vertical grid
  for (int i = -80; i <= 400; i += ticksIAS)
  {
    line(i, 0, i, -hitScaling * MAX_HITS - 3);
  }
  // horizontal grid
  for (int i = 1; i <= MAX_HITS; i++)
  {
    line(-80 - 3, -i * hitScaling, 400 + 3, -i * hitScaling);
  }
  
  // Draw distribution
  float prevAvg = 0;
  for (int i = -80; i <= 400; i += incrementIAS)
  {
    float average = 0;
    for (int j = 0; j < MAX_HITS; j++)
    {
      int hits = results[i+80][j];
      float probability = hits / float(simCount);
      average += j * probability;
      
      noStroke();
      fill(color(0, 254 * (probability) + 1)); // Does this look weird? Well, (0, 0) is black!
      rect(i, -j * hitScaling, incrementIAS, -hitScaling);
    }
    
    stroke(color(255, 0, 0));
    line(i-incrementIAS, -prevAvg * hitScaling, i, -average * hitScaling);
    prevAvg = average;
  }  
  
  // Draw axes
  stroke(0);
  fill(0);
  textSize(8);
  // x-axis
  line(-80 - 10, 0, IAS_COUNT - 80 + 10, 0);  
  pushMatrix();
  translate(IAS_COUNT - 80 + 10, 0);
  line(0, 0, -2, -2);
  line(0, 0, -2, 2);
  popMatrix();
  // y-axis
  line(0, 0, 0, -hitScaling * MAX_HITS - 10);
  pushMatrix();
  translate(0, -hitScaling * MAX_HITS - 10);
  line(0, 0, -2, 2);
  line(0, 0, 2, 2);
  popMatrix();
  
  // x-axis labels
  textAlign(CENTER, TOP);
  for (int i = -80; i <= 400; i += ticksIAS)
  {
    line(i, -2, i, 2);
    
    text(str(i), i, 5);
  }
  // y-axis labels (no need to start at 0)
  textAlign(RIGHT, CENTER);
  for (int i = 1; i < MAX_HITS+1; i++)
  {
    line(-2, -i * hitScaling, 2, -i * hitScaling);
   
    text(str(i), -80 - 6, -i * hitScaling - 1 );
  }
  popMatrix();
  
  
  textAlign(LEFT, TOP);
  textSize(12);
  int m = millis() - startMillis;
  text("Simulated: " + str(simCount) +
        " in " + str(m / 1000.0) + " seconds (" + 
        str(simCount*1000/m) + "/second)", 10, 10);
  
  if (simCount == 200000) mousePressed();
}


int SimulateOnce(int IAS)
{
  int finishedAttacks = 0;
  
  float cooldown = 0;
  float attackTime = BAT / (1.0 + IAS / 100.0);
  float frontswingTime = FRONTSWING / (1.0 + IAS / 100.0);
  
  for (int slash = 0; slash < MAX_SLASHES; slash++)
  {
    float timeSpent = 0;
    timeSpent += cooldown;
    
    // Reaction delay (only gets applied on the first attack of the chain!)
    float reactionDelay = random(0.25);
    while (true)
    {
      // Still have time to complete frontswing?
      if (timeSpent + reactionDelay + frontswingTime < 0.4)
      {
        // Yes, attack connects.
        timeSpent += reactionDelay + attackTime;
        finishedAttacks++;
        // Reaction delay only applies for the first attack.
        reactionDelay = 0;
      }
      else break; // Will get interrupted by repositioning.
    }
    
    if (timeSpent > 0.4) cooldown = timeSpent - 0.4;
    else cooldown = 0;
    // (could just do this with timeSpent, too, but let's be elaborate) 
  }
  return finishedAttacks;
}


void mousePressed()
{
  saveFrame("Omnislash_" + str(LEVEL+1) + ".png");
}

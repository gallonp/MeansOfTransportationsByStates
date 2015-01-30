import org.gicentre.geomap.*;
import controlP5.*;
import processing.data.Table;
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
GeoMap geoMap;                // Declare the geoMap object.
ControlP5 cp5;
PImage littleMan;


String [][] csv;
String[] statesname;
int[][] csvdata = new int[51][6] ;
String[] temp;
String stateselect;
int csvWidth=0;
int statenum=0;
int xnow=0;
int ynow=0;
int[] colors;
Range range;
int mode =0;
float upperbound =100;
float lowerbound =0;
int max = 0;
int mousexmo;
int mouseymo;
Table csvTable;
float highvalue=100;
float lowvalue=0;
float rangevalue=100;
String stateselabb;
int iffirst=1;
float[] DAR = new float[51];
float[] CPR = new float[51];
float[] PBR = new float[51];
float[] WKR = new float[51];
float[] OTR = new float[51];
float[] WHR = new float[51];
float[] DAN = new float[51];
float[] CPN = new float[51];
float[] PBN = new float[51];
float[] WKN = new float[51];
float[] OTN = new float[51];
float[] WHN = new float[51];
float mouseovervalue;
Queue<Float> DAQ;
Queue<Float> CPQ;
Queue<Float> PBQ;
Queue<Float> WKQ;
Queue<Float> OTQ;
Queue<Float> WHQ;

Queue<Float> DANQ;
Queue<Float> CPNQ;
Queue<Float> PBNQ;
Queue<Float> WKNQ;
Queue<Float> OTNQ;
Queue<Float> WHNQ;




List<ChartItem> chartRatioItems =  new ArrayList<ChartItem>();
List<ChartItem> chartNumItems =  new ArrayList<ChartItem>();

public class ChartItem{
  public String stateName;
  public float value;
  public final int itemColor;
  public final int order;
  public final String type;
  public final float x;
  public final float y;
  
  public ChartItem(int itemColor, int order, String type, float x, float y){
        this.itemColor = itemColor;
        this.order = order;
        this.type = type;
        this.x = x;
        this.y = y;
  }
}

String currentMouseOverState = null;

void buildTable(){
 
   csvTable = loadTable("CommuterData.csv","header");
   csvTable.removeRow(0);  // Removes the first row

//   println(csvTable.getRowCount() + " total rows in table"); 
   csvTable.addColumn("DA_Ratio",Table.FLOAT);
   csvTable.addColumn("CP_Ratio",Table.FLOAT);
   csvTable.addColumn("PB_Ratio",Table.FLOAT);
   csvTable.addColumn("WK_Ratio",Table.FLOAT);
   csvTable.addColumn("OT_Ratio",Table.FLOAT);
   csvTable.addColumn("WH_Ratio",Table.FLOAT);

   for (int i=0; i < csvTable.getRowCount(); i++) {
     TableRow row = csvTable.getRow(i);
     int total = row.getInt("Total Workers");
     int DA = row.getInt("Drove Alone");
     int CP = row.getInt("Car-pooled");
     int PB = row.getInt("Used Public Transportation");
     int WK = row.getInt("Walked");
     int OT = row.getInt("Other");
     int WH = row.getInt("Worked at home");
     csvdata[i][0]=DA;
     csvdata[i][1]=CP;
     csvdata[i][2]=PB;
     csvdata[i][3]=WK;
     csvdata[i][4]=OT;
     csvdata[i][5]=WH;
     DAR[i]=(float)DA/total;
     CPR[i]=(float)CP/total;
     PBR[i]=(float)PB/total;
     WKR[i]=(float)WK/total;
     OTR[i]=(float)OT/total;
     WHR[i]=(float)WH/total;
     DAN[i]=(float)DA/10000;
     CPN[i]=(float)CP/10000;
     PBN[i]=(float)PB/10000;
     WKN[i]=(float)WK/10000;
     OTN[i]=(float)OT/10000;
     WHN[i]=(float)WH/10000;
     String name = geoMap.getAttributes().getString(i, 2);
     csvTable.setString(i,"Abbrev",name);
     csvTable.setFloat(i,"DA_Ratio",((float)DA/total));
     csvTable.setFloat(i,"CP_Ratio",((float)CP/total));
     csvTable.setFloat(i,"PB_Ratio",((float)PB/total));
     csvTable.setFloat(i,"WK_Ratio",((float)WK/total));
     csvTable.setFloat(i,"OT_Ratio",((float)OT/total));
     csvTable.setFloat(i,"WH_Ratio",((float)WH/total));     
   }

   updateTopThree(1,0);
 
}

void updateTopThree(float upper,float lower){
   if(mode ==0){
    
   DAQ = getQueueInRange(upper,lower,DAR);
   CPQ = getQueueInRange(upper,lower,CPR);
   PBQ = getQueueInRange(upper,lower,PBR);
   WKQ = getQueueInRange(upper,lower,WKR);
   OTQ = getQueueInRange(upper,lower,OTR);
   WHQ = getQueueInRange(upper,lower,WHR);
   int stateNum;
   int j =0;
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (DAQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value =DAQ.poll();
     stateNum = getStateNumInRatio(DAR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (CPQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value =CPQ.poll();
     stateNum = getStateNumInRatio(CPR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (PBQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value = PBQ.poll();
     stateNum = getStateNumInRatio(PBR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (WKQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value =WKQ.poll();
     stateNum = getStateNumInRatio(WKR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (OTQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value =OTQ.poll();
     stateNum = getStateNumInRatio(OTR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartRatioItems.get(j);
     if (WHQ.peek() == null){
         item.value = 0;
         item.stateName ="N/A";
         chartRatioItems.set(j,item);
         j++;
         continue;
     }
     item.value =WHQ.poll();
     stateNum = getStateNumInRatio(WHR, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartRatioItems.set(j,item);
     j++;
   }

 }
 else{
//
  
   DANQ = getNumQueueInRange(upper,lower,"Drove Alone");
   CPNQ = getNumQueueInRange(upper,lower,"Car-pooled");
   PBNQ = getNumQueueInRange(upper,lower,"Used Public Transportation");
   WKNQ = getNumQueueInRange(upper,lower,"Walked");
   OTNQ = getNumQueueInRange(upper,lower,"Other");
   WHNQ = getNumQueueInRange(upper,lower,"Worked at home");

   int stateNum;
   int j =0;
   for(int i = 0; i<3;i++){
     ChartItem item = chartNumItems.get(j);
     if (DANQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = DANQ.poll();
     stateNum = getStateNumInRatio(DAN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartNumItems.get(j);
     if (CPNQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = CPNQ.poll();
     stateNum = getStateNumInRatio(CPN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartNumItems.get(j);
     if (PBNQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = PBNQ.poll();
     stateNum = getStateNumInRatio(PBN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;

   }
   for(int i = 0; i<3;i++){
    ChartItem item = chartNumItems.get(j);
    if (WKNQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = WKNQ.poll();
     stateNum = getStateNumInRatio(WKN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
    ChartItem item = chartNumItems.get(j);
    if (OTNQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = OTNQ.poll();
     stateNum = getStateNumInRatio(OTN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;
   }
   for(int i = 0; i<3;i++){
     ChartItem item = chartNumItems.get(j);
     if (WHNQ.peek() == null){
         item.value = 0;
         item.stateName ="NA";
         chartNumItems.set(j,item);
         j++;
         continue;
     }
     item.value = WHNQ.poll();
     stateNum = getStateNumInRatio(WHN, item.value);
     item.stateName = csvTable.getString(stateNum,"Abbr");
     chartNumItems.set(j,item);
     j++;
   }
 
 }
}



int getStateNumInRatio(float[] ratios,float ratio){
  int x = 0;
  for(float r : ratios) {
       if (r == ratio){
         return x;
       }
       x++;
     }
   return -1;
}


Queue getNumQueueInRange(float upper,float lower,String type){
  
   Queue q = new PriorityQueue<Float>(51,Collections.reverseOrder());
   float total ;
//   int value ;
//  print
   for(int i = 0; i<51;i++){
     TableRow row = csvTable.getRow(i);
     total = row.getFloat("Total Workers");
     if (total/10000 >= lower && total/10000 <= upper){
       q.add(row.getFloat(type)/10000);
     }
     
   }
//  print(q.poll()+"\n");
  return q;
}

Queue getQueueInRange(float upper,float lower,float[] valueArray){
   Queue q = new PriorityQueue<Float>(51,Collections.reverseOrder());
   for (float value  : valueArray){
     if (value >=lower && value <= upper){
       q.add(value);
     }
   }
  return q;
}

void setup()
{
//  ChartItem(int itemColor, int order, String type, float x, float y)
  chartRatioItems.add(new ChartItem(#833A40,1,"DA",110,350));
  chartRatioItems.add(new ChartItem(#833A40,2,"DA",110,440));
  chartRatioItems.add(new ChartItem(#833A40,3,"DA",110,530));
  chartRatioItems.add(new ChartItem(#E3742B,1,"CP",230,350));
  chartRatioItems.add(new ChartItem(#E3742B,2,"CP",230,440));
  chartRatioItems.add(new ChartItem(#E3742B,3,"CP",230,530));
  chartRatioItems.add(new ChartItem(#DCA82E,1,"PB",350,350));
  chartRatioItems.add(new ChartItem(#DCA82E,2,"PB",350,440));
  chartRatioItems.add(new ChartItem(#DCA82E,3,"PB",350,530));
  chartRatioItems.add(new ChartItem(#BCAE68,1,"WK",470,350));
  chartRatioItems.add(new ChartItem(#BCAE68,2,"WK",470,440));
  chartRatioItems.add(new ChartItem(#BCAE68,3,"WK",470,530));
  chartRatioItems.add(new ChartItem(#A4B462,1,"OT",590,350));
  chartRatioItems.add(new ChartItem(#A4B462,2,"OT",590,440));
  chartRatioItems.add(new ChartItem(#A4B462,3,"OT",590,530));
  chartRatioItems.add(new ChartItem(#7CA8AC,1,"WH",710,350));
  chartRatioItems.add(new ChartItem(#7CA8AC,2,"WH",710,440));
  chartRatioItems.add(new ChartItem(#7CA8AC,3,"WH",710,530));

  //chartnumitem
  chartNumItems.add(new ChartItem(#833A40,1,"DA",90,330));
  chartNumItems.add(new ChartItem(#833A40,2,"DA",112,330));
  chartNumItems.add(new ChartItem(#833A40,3,"DA",134,330));
  chartNumItems.add(new ChartItem(#E3742B,1,"CP",210,330));
  chartNumItems.add(new ChartItem(#E3742B,2,"CP",232,330));
  chartNumItems.add(new ChartItem(#E3742B,3,"CP",254,330));
  chartNumItems.add(new ChartItem(#DCA82E,1,"PB",330,330));
  chartNumItems.add(new ChartItem(#DCA82E,2,"PB",352,330));
  chartNumItems.add(new ChartItem(#DCA82E,3,"PB",374,330));
  chartNumItems.add(new ChartItem(#BCAE68,1,"WK",450,330));
  chartNumItems.add(new ChartItem(#BCAE68,2,"WK",472,330));
  chartNumItems.add(new ChartItem(#BCAE68,3,"WK",494,330));
  chartNumItems.add(new ChartItem(#A4B462,1,"OT",570,330));
  chartNumItems.add(new ChartItem(#A4B462,2,"OT",592,330));
  chartNumItems.add(new ChartItem(#A4B462,3,"OT",614,330));
  chartNumItems.add(new ChartItem(#7CA8AC,1,"WH",690,330));
  chartNumItems.add(new ChartItem(#7CA8AC,2,"WH",712,330));
  chartNumItems.add(new ChartItem(#7CA8AC,3,"WH",734,330));
  
  
  String data[] = loadStrings("CommuterData.csv");
  size(900, 700);
  littleMan = loadImage("man.gif");

  geoMap = new GeoMap(10,10,400,250,this);  // Create the geoMap object.
  geoMap.readFile("usContinental");   // Reads shapefile.
  //  geoMap.getAttributes().writeAsTable(5);
  buildTable();
  cp5 = new ControlP5(this); 
  range = cp5.addRange("")
           // disable broadcasting since setRange and setRangeValues will trigger an event
           .setBroadcast(false) 
           .setPosition(90,620)
           .setSize(680,25)
           .setHandleSize(20)
           .setRange(lowerbound,upperbound)
           .setRangeValues(0,100)
           // after the initialization we turn broadcast back on again
           .setBroadcast(true)
           .setColorForeground(color(255,40))
           .setColorBackground(color(255,40))  
           ;
             
  noStroke();  
  
  //button
    // create a new button with name 'buttonA'
  cp5.addButton("Number")
     .setValue(0)
     .setPosition(780,290)
     .setSize(80,20)
     ;
  
  // and add another 2 buttons
  cp5.addButton("Percentage")
     .setValue(100)
     .setPosition(780,330)
     .setSize(80,20)
     ;

  //calculate max width of csv file
    for (int i=0; i < data.length; i++) {
      String [] chars=split(data[i],',');
      if (chars.length>csvWidth){
        csvWidth=chars.length;
      }
    }

    //create csv array based on # of rows and columns in csv file
    csv = new String [data.length-1][csvWidth];
    
    //parse values into 2d array (from 2nd line)
    for (int i=0; i < data.length-1; i++) {
      temp = new String [data.length];
      temp= split(data[i+1], ',');
      for (int j=0; j < temp.length; j++){
       csv[i][j]=temp[j];
      }
    }
    
    //create statesname array
      statesname = new String[data.length-2];
    for (int i=0; i < data.length-2; i++) {
      temp = new String [data.length];
      temp= split(data[i+2], ',');
      statesname[i] = temp[0];
    }
      max = 1800;
      background(20,36,62);   
}

int currentHightLightedSate=-1;
int StateChanged = -1;
int currentState;
int lastMode=0;
int rangeChanged=0;
void draw()
{ 
  checkMouseHover();
  background(20,36,62);
  drawWorldMap();
  drawPart1();
  drawPart2();
  mouseOverHighlightState();
}

void checkMouseHover(){
       currentMouseOverState = getCurrentMouseOverState();
      
}  


String getCurrentMouseOverState(){
  if(mode==0){
      for (Iterator<ChartItem> itr = chartRatioItems.iterator(); itr.hasNext();){
         int x = mouseX;
         int y = mouseY;
         ChartItem item = itr.next();
         if (dist(x,y,item.x,item.y)<30){
             text(item.stateName+" "+mouseX+" "+mouseY,mouseX,mouseY);
             return item.stateName;
         }
       }
       return null;
     }
    else if(mode ==1){
        for (Iterator<ChartItem> itr = chartNumItems.iterator(); itr.hasNext();){
         int x = mouseX;
         int y = mouseY;
         
         ChartItem item = itr.next();
        if(x>=item.x&&x<=item.x+21&&((560-item.value/1150*230)<=y)&&y<=560){
          mouseovervalue=item.value;
          mousexmo = mouseX;
          mouseymo = mouseY;
          return item.stateName;
        }
       }
       return null;
    }
    return null;
}



void drawWorldMap(){
  strokeWeight(1);
   fill(20,36,62);   
   stroke(20,36,62); 
  rect(0, 0, 480,260);
    // Ocean colour
   fill(250,184,127);        // Land colour
  stroke(0,80);               // Boundary colour
  geoMap.draw();              // Draw the entire map.
  // Draw the frame line
  strokeWeight(1);
  if(iffirst==1){
     fill(189,190,147);   
    geoMap.draw(44);
    text("Alabama", 30,260);
       
  }
    else{
        if (currentHightLightedSate != -1)
        {
            fill(189,190,147);      // Highlighted land colour.
            geoMap.draw(currentHightLightedSate);
            text(stateselect, 30,260);
          }
      }
}


void drawPart1(){
  int id = currentHightLightedSate;
  drawPart1Chart()  ;
}


void drawPart2(){
  //by percentage
  if(mode==0){
  for (Iterator<ChartItem> itr = chartRatioItems.iterator(); itr.hasNext();) {
        ChartItem item = itr.next();
        String temp = csvTable.getString(statenum,"Abbr");
        if (item.stateName == currentMouseOverState ||item.stateName == temp) {
            strokeWeight(3);
            if(item.stateName == currentMouseOverState){
              stroke(255,255,255);}
            else{
               stroke(#ff1493);
            }
          } else {
            strokeWeight(0);
            stroke(20,36,62);
          }

        drawPart2shell(item.x,item.y,item.value,item.itemColor);
       text(item.stateName+": "+String.format("%.2f%%",item.value*100),item.x-20,item.y+50);
  }
    fill(220,226,178);
    text("Drove Alone",80,300);
    text("Car-pooled",200,300);
    text("Public Trans.",320,300);
    text("   Walked",440,300);
    text("   Other",560,300);
    text("   Home",680,300);  
   }

  
  else{
//by number
  fill(#FFFFFF);
  textSize(10);
  text("*10000",770,637);
  fill(#14243E);
  rect(80,300,680,280);
  textSize(14);
  fill(220,226,178);
  text("Drove Alone",80,300);
  text("Car-pooled",200,300);
  text("Public Trans.",320,300);
  text("   Walked",440,300);
  text("   Other",560,300);
  text("   Home",680,300);
  if(mouseX==mousexmo&&mouseY==mouseymo){
  text(mouseovervalue,mousexmo+5,mouseymo-5);}
  int i=2;
    for (Iterator<ChartItem> itr = chartNumItems.iterator(); itr.hasNext();) {
        ChartItem item = itr.next();
        if(item.stateName!=null){
          String temp = csvTable.getString(statenum,"Abbr");
         if (item.stateName == currentMouseOverState ||item.stateName == temp) {
            strokeWeight(2);
            if(item.stateName == currentMouseOverState){
              stroke(255,255,255);}
            else{
               stroke(#ff1493);
            }  
          }
         else {
            strokeWeight(0);
          }
        if(i==-1){
        i=2;}
          color c = color (item.itemColor,150+i*70);
        drawPart2bar(item.x,item.value,c);
       text(item.stateName,item.x,580);
       i--;
      }
       else{
       text("NA",item.x,580);
       }
  }
 }
   
} 

void drawPart2shell(float x, float y,float perc,int colorshell){
   perc=PI/180*perc*360-0.5*PI;
   fill(colorshell);
   arc(x, y, 60, 60, -0.5*PI, perc, PIE);
}

void drawPart2bar(float x, float num, int colorbar){
  float heightbar =num/1150*230;
  float y = 560-heightbar;
  fill(colorbar);
  rect(x,y,21,heightbar);
}


void drawPart1Chart(){

 fill(20,36,62);
    stroke(20,36,62);
    rect(450,0,430,260);
    int left=580;
    //draw axis
    fill(180, 0, 220);
    stroke(0);
    strokeWeight(2);
    line(left-15, 260, left-15, 10);
     line(left-135, 260, left-135, 10);
    //draw labels
    textSize(14); 
    fill(255,255,255);

    int c = #833A40;
    
    //draw each group
    //The  fifth param is the number of people for that group
    
    int total = csvTable.getInt(statenum,"Total Workers");
    float temp = float(csvTable.getInt(statenum,"Drove Alone"));
    float num = temp/total*100;
    int h1 = drawPeople(10,left,18,10,num,20,c);
    fill(220,226,178);
    text("Drive Alone", left-105, 5+10+h1/2);

    c = #E3742B;
    temp = float(csvTable.getInt(statenum,"Car-pooled"));
    num =( temp/total*100);
    int h2 = drawPeople(10*2+h1,left,18,10,num,20,c);
    fill(220,226,178);  
    text("Car-pooled", left-105, 5+10*2+h1+h2/2);
  
  
    c = #DCA82E;
    temp = float(csvTable.getInt(statenum,"Used Public Transportation"));
    num =( temp/total*100);
    int h3 = drawPeople(10*3+h1+h2,left,18,10,num,20,c);
     fill(220,226,178);
    text("Used Public", left-105, 5+10*3+h1+h2+h3/2);
    text("Transportation", left-122, 15+10*3+h1+h2+h3/2);

    c = #BCAE68;
    temp = float(csvTable.getInt(statenum,"Walked"));
    num =( temp/total*100);
    int h4 = drawPeople(10*4+h1+h2+h3,left,18,10,num,20,c);
     fill(220,226,178);
    text("Walked", left-75, 5+10*4+h1+h2+h3+h4/2);
  
    c = #A4B462;
    temp = float(csvTable.getInt(statenum,"Other"));
    num =( temp/total*100);
    int h5 = drawPeople(10*5+h1+h2+h3+h4,left,18,10,num,20,c);
     fill(220,226,178);
    text("Other", left-68, 5+10*5+h1+h2+h3+h4+h5/2);
    
    c = #7CA8AC;
    temp = float(csvTable.getInt(statenum,"Worked at home"));
    num =( temp/total*100);
    int h6 = drawPeople(10*6+h1+h2+h3+h4+h5,left,18,10,num,20,c);
     fill(220,226,178);
    text("Work at home ", left-117, 5+10*6+h1+h2+h3+h4+h5+h6/2);
    int check = checkmouseover(10+h1/2-5,10*2+h1+h2/2-5,10*3+h1+h2+h3/2-5,10*4+h1+h2+h3+h4/2-5,10*5+h1+h2+h3+h4+h5/2-5,10*6+h1+h2+h3+h4+h5+h6/2-5);
    fill(#FFFFFF);
    if(check ==0){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
    else  if(check ==1){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
     else  if(check ==2){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
     else  if(check ==3){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
     else  if(check ==4){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
     else  if(check ==5){
      text(csvdata[statenum][check],mouseX+5,mouseY-5);
    }
   
}
int checkmouseover(int h1,int h2,int h3,int h4,int h5,int h6){
  if(mouseX<565&&mouseX>450&&mouseY<260&&mouseY>10){
    if(mouseY>h1&&mouseY<h1+15){
      return 0;
    }
    else if(mouseY>h2&&mouseY<h2+15){
      return 1;
    }
    else if(mouseY>h3&&mouseY<h3+25){
      return 2;
    }
    else if(mouseY>h4&&mouseY<h4+15){
      return 3;
    }
    else if(mouseY>h5&&mouseY<h5+15){
      return 4;
    }
  else if(mouseY>h6&&mouseY<h6+15){
      return 5;
    }
    else{
      return -1;
    }
  }
      return -1;
}
int drawPeople(int top,int left,int h, int w, float num, int rowMax, int c){
  float fraction = num%1;
  num = num - fraction;
  
  int row = 0;
  
  while(num>=rowMax){
    
      for (int i=0; i<rowMax ;i++) {
        tint(c);
        image(littleMan, left+i*(w+1), top+row*(h+2),w,h);
      }
      num-=rowMax;
      row++;
  }
  int i;
  for (i=0; i<num ;i++) {
      tint(c);
      image(littleMan, left+i*(w+1), top+row*(h+2),w,h);
  }
  tint(c);
  image(littleMan, left+(i)*(w+1), top+row*(h+2),w,h);
  float fw = w*(1-fraction);
  int wf = int(fw);
  fill(20,36,62);
  stroke(0,0);
  strokeWeight(0);
  rect( left+i*(w+1)+w,top+row*(h+2),-wf,h);
  num-=rowMax;
  noTint();
  return (h+2)*(row+1);
}

void mouseOverHighlightState(){
  int id = (geoMap.getID(mouseX, mouseY));
  if (id != -1)
  {
    fill(180, 120, 120);      // Highlighted land colour.
    geoMap.draw(id);
    String name = geoMap.getAttributes().getString(id, 3);
     stateselabb = geoMap.getAttributes().getString(id, 2);
    
    fill(84,141,117);
    if (mouseX<320){
          text(name, mouseX+5, mouseY-5);
      } else{
          text(name, mouseX-name.length()*6, mouseY-5);
      }
  }
}

void mousePressed(){
  int id = (geoMap.getID(mouseX, mouseY));
  if (id != -1)
  { currentHightLightedSate = id;
     iffirst=0;
    stateselect = geoMap.getAttributes().getString(id, 3);
    String temp = stateselect+" ";
    statenum=0;
    while((temp.equals(statesname[statenum])==false)&&statenum<=52){
      statenum++;
    }
  
 }
}

//controller button "number"
public void Number(){
  mode =1;
  upperbound =1800;
  lowerbound =0;
  rangevalue=1800;
  range.setRange(lowerbound,upperbound);
  range.setRangeValues(0,rangevalue);
//  updateTopThree(highvalue,lowvalue);
}

//controller button "percentage"
public void Percentage(){
  mode =0;
  upperbound =100;
  lowerbound =0;
  rangevalue=100;
  range.setRange(lowerbound,upperbound);
  range.setRangeValues(0,rangevalue);

}

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("")) {
    if(mode==0){
      highvalue = theControlEvent.getController().getArrayValue(1)/100;
      lowvalue = theControlEvent.getController().getArrayValue(0)/100;
      updateTopThree(highvalue,lowvalue);
    } else {
        
        highvalue = theControlEvent.getController().getArrayValue(1);
        lowvalue = theControlEvent.getController().getArrayValue(0);
        updateTopThree(highvalue,lowvalue);
      }
  }
  
}




















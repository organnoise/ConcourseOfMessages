SerialIO serial;
string line;
string stringInts[2];
int data[2];
2 => int digits;

SerialIO.list() @=> string list[];
for( int i; i < list.cap(); i++ )
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}
serial.open(6, SerialIO.B9600, SerialIO.ASCII);

fun void serialPoller(){
    while( true )
    {
        // Grab Serial data
        serial.onLine()=>now;
        serial.getLine()=>line;
        
        if( line$Object == null ) continue;
        if( line == "\n" ) continue;
        
        0 => stringInts.size;
        
        // Line Parser
        
        string pattern;
        "\\[" => pattern;
        for(int i;i<digits;i++){
            "([0-9]+)" +=> pattern;
            if(i<digits-1){
                "," +=> pattern;
            }
        }
        "\\]" +=> pattern;
        if (RegEx.match(pattern, line , stringInts))
        {
            for( 1=>int i; i<stringInts.cap(); i++)  
            {
                // Convert string to Integer
                Std.atoi(stringInts[i])=>data[i-1];
            }
        }
        
        <<< data[0], data[1]>>>;
    }
       
}

spork ~ serialPoller();

2 => int NUM_BUTTONS;

int bState[NUM_BUTTONS];
int bLastState[NUM_BUTTONS];

// send object
OscOut osc;
osc.dest("localhost", 12500);


while (true)
{
    buttonUpdate();
    5::ms => now;
}

//Find button serial data and turn it into an OSC message
fun void buttonUpdate(){
    //Iterate through the data from serial
    for(0 => int i; i < NUM_BUTTONS; i++){
        //First piece of data indicates which button it is
        //Second piece of data is that button's value
        if(data[0] == i) data[1] => bState[i];
        
        //If the state is different, send an 
        //OSC message of the newstate
        if(bState[i] != bLastState[i])oscOut("/b" + i, bState[i]);
        
        //Replace the state
        bState[i] => bLastState[i];
    }
    
}

// osc sending function
fun void oscOut(string addr, int val) {
    osc.start(addr);
    osc.add(val);
    osc.send();
}

//Cleaned up version of the original code - Michael
//Sources: 
//Original: https://web.archive.org/web/20151012175118/http://steike.com/code/multitouch/
//Reverse engineered multitouch framework: https://github.com/calftrail/Touch/blob/master/TouchSynthesis/MultitouchSupport.h

#include <math.h>
#include <unistd.h>
#include <CoreFoundation/CoreFoundation.h>

typedef struct {
    float x;
    float y;
} MTPoint;

typedef struct {
    MTPoint pos;
    MTPoint vel;
} MTVector;

typedef struct {
    int frame;
    double timestamp;
    int pathIndex;  // "P" (~transducerIndex)
    int state;
    int fingerID;   // "F" (~identity)
    int handID;     // "H" (always 1)
    MTVector normalizedVector;
    float zTotal;       // "ZTot" (~quality, multiple of 1/8 between 0 and 1)
    int field9;     // always 0
    float angle;
    float majorAxis;
    float minorAxis;
    MTVector absoluteVector;    // "mm"
    int field14;    // always 0
    int field15;    // always 0
    float zDensity;     // "ZDen" (~density)
} MTTouch;

typedef void* MTDeviceRef;
typedef void (*MTContactCallbackFunction)(int, MTTouch*, int, double, int);

MTDeviceRef MTDeviceCreateDefault();
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int); 

void MTFrameCallbackFunc(int device, MTTouch *touchArray, int numTouches, double timestamp, int frame) {
    for (int i = 0; i < numTouches; ++i) {
        MTTouch *current = &touchArray[i];

        /* Compare normalized vectors vs absolute vectors
        printf("Frame: %7d; NPos(%6.3f, %6.3f); APos(%6.3f, %6.3f); NVel(%6.3f, %6.3f); AVel(%6.3f, %6.3f)\n",
            current->frame,
            current->normalizedVector.pos.x, current->normalizedVector.pos.y, 
            current->absoluteVector.pos.x, current->absoluteVector.pos.y, 
            current->normalizedVector.vel.x, current->normalizedVector.vel.y, 
            current->absoluteVector.vel.x, current->absoluteVector.vel.y 
            );
        */

        printf("Frame: %7d; ID: %2d; absPos(%6.3f, %6.3f); absVel(%6.3f, %6.3f); Ellipse(%5.2fx%5.2f); zTotal(%5.3f); zDensity(%2.3f); \n",

            current->frame,  
            current->fingerID, 
            current->absoluteVector.pos.x, current->absoluteVector.pos.y,
            current->absoluteVector.vel.x, current->absoluteVector.vel.y, 
            current->majorAxis, current->minorAxis, 
            current->zTotal, 
            current->zDensity
            );
    }
}

int main() {
    MTDeviceRef dev = MTDeviceCreateDefault();
    MTRegisterContactFrameCallback(dev, MTFrameCallbackFunc);
    MTDeviceStart(dev, 0);
    /* ctrl-c gets rid of buffered write calls from printf. need to rewrite this.
    printf("Ctrl-C to abort\n");
    sleep(-1);
    */
    printf("Touchpad recording started.\n"
        "Note: this script only records touchpad data. It CANNOT see:\n"
        "- keyboard inputs\n"
        "- mouse inputs\n"
        "- anything else going on in your computer\n"
        "To exit safely, input 'q' into Terminal (press q then enter).\n");
    char c;
    while (1) {
        c = getchar();
        if (c == 'q')
            break;
    }
    return 0;
}
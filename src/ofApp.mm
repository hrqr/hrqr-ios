/**
 * Created by Valentin Heun on 9/14/15.
 *
 * Copyright (c) 2015 Valentin Heun
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */


#include "ofApp.h"

using namespace cv;
using namespace ofxCv;

//--------------------------------------------------------------
void ofApp::setup(){
    
    
    
    string finalBit = "";
    
    
    
    for(int w = 0; w<139;w++){
        
        // needs to be filled with array of 21. somehow I can not get the size of an array.
        
        finalBit += ofToString(bitNumber(bitA[w]))+", \n";
        
    }
    ofLog()<< "indx: " << finalBit;
    
    
    
    
    ofBackground(0,0,0);
    //  cam.initGrabber(480, 360);
      cam.initGrabber(640, 480);
    //        cam.initGrabber(640, 480);
    
    //cam.setup(360, 480);

    // cam.initGrabber(360, 480);
    // cam.setDesiredFrameRate(15);
    //  myGrabber.initGrabber(320,240);
    
      cam.videoSettings();
    
    float boxSizeH = 45;
    
    float boxSizeW = 58;
    long boxPad = 5;
    
    abcImg.load("abc.png");
    setImg.load("setup.png");
    backImg.load("back.png");
    
    ofLog() << abcImg.getHeight()/abcImg.getWidth();
    
    abcRect.set(boxPad*2,boxPad*2 , boxSizeW,boxSizeH);
    
    setRect.set((boxPad*4)+boxSizeW,boxPad*2 , boxSizeW,boxSizeH);
    
    
    backRect.set((boxPad*6)+(boxSizeW*2),boxPad*2 ,boxSizeW ,boxSizeH);
    
    
    
    W = cam.getWidth(); // width;
    H = cam.getHeight();// height;
    
 
    
    ofLog() << "dasist hoch und breit" << W << " " << H;
    
    HS = 480;
    
    ofSetFrameRate(30);
    contourFinder.setMinAreaRadius(30);
    contourFinder.setMaxAreaRadius(1500);
    
    camST.load("mona.jpg");
    thresh.allocate(W, H, OF_IMAGE_GRAYSCALE);
    workImageTrans.allocate(HS, HS, OF_IMAGE_GRAYSCALE);
    

    workImage.allocate(W, H, OF_IMAGE_GRAYSCALE);
    
    contourFinder.setTargetColor(0, TRACK_COLOR_RGB);
    contourFinder.setThreshold(127);
    
    
    fbo.allocate(W, H, GL_RGBA);
        fbo3.allocate(HS, HS, GL_RGBA);
    
    
    img.allocate(W,H,OF_IMAGE_COLOR);
    
    pixels.allocate(H, H, OF_IMAGE_GRAYSCALE);
    
    ofSetLineWidth(5);
    
    /**********************************************
     INITIALIZING THE INTERFACE
     **********************************************/
    interface.initializeWithCustomDelegate(this);
    interface.loadLocalFile("dummy","page");
    // interface.loadURL("http://www.valentinheun.com");
    
    interface.activateView();
    
    
}



/**********************************************
 HANDLING REQUESTS FROM JS/HTML (JS->C++)
 **********************************************/
void ofApp::handleCustomRequest(NSString *request) {
    // NSLog(@"------------------------------------------------------------%@", request);
    string reqstring([request UTF8String]);
    
    ofLog() << reqstring;
    
    
    if(reqstring == "webExternal"){
        setWebLocal = false;
    }
    
    if(reqstring == "webLocal"){
        setWebLocal = true;
    }
    
    
    if(reqstring == "getWebLocal"){
        NSString *jsString3 ;
        if(setWebLocal){
            jsString3 = [NSString stringWithFormat:@"setState('yes')"];}
        else{
            jsString3 = [NSString stringWithFormat:@"setState('no')"];
        }
        
        
        interface.runJavaScriptFromString(jsString3);
    }
    
    
    if(reqstring == "getText"){
        
        
        ofLog()<< "got it";
        ofLog()<< "sending: " << webText;
        
        NSString *jsString3 = [NSString stringWithFormat:@"setText('%s')", webText.c_str()];
        interface.runJavaScriptFromString(jsString3);
        
    }
    
    if(reqstring == "killText"){
        
        webText ="";
        
    }
    
    /*  NSString *jsString3 = [NSString stringWithFormat:@"addHeartbeatObject(%s)", nameCount[i][0].c_str()];
     interface.runJavaScriptFromString(jsString3);*/
    ofLog() << setWebLocal;
    
}

//--------------------------------------------------------------
// reponder for the asychronus file loader.
void ofApp::urlResponse(ofHttpResponse &response) {
    // if the file is ok and the request message name equals the file downloader process name,
    // in this case "done" the folloing code is run.
    //  if (response.status == 200 && response.request.name == "done") {
    
    
}



//--------------------------------------------------------------
void ofApp::update(){
    // if(interfaceActivity == 0){
    cam.update();
    //      }
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    
    ofBackground(127);
    if(interfaceActivity == 0 || interfaceActivity == 4){
        
        
        fbo.begin();
        ofBackground(0);
        cam.draw(0, 0);
        
        
        
        
        if(cam.isFrameNew())
        {
            
        
            
            
         //   img.setFromPixels(cam.getPixels(), W, H, OF_IMAGE_COLOR);
            
            
            
            
            
            // drawOrnot = true;
            homographyReady = false;
            
           // convertColor(img, thresh, CV_RGB2GRAY);
            
                	convertColor(cam, thresh, CV_RGB2GRAY);
            
            copy(thresh, workImage);
            
            workImage.update();
            
               //  thresh.draw(0, 0);
            
            
            erode(thresh, thresh, 4);
            
             thresh.update();
        //  thresh.draw(0, 0);
            
            //  threshold(thresh, 127);
            
            contourFinder.findContours(thresh);
            
            
            long n = contourFinder.size();
            
            if(n>0){
                for(int i = 0; i < n; i++) {
                    
                    
                    ofPolyline convexHull = toOf(contourFinder.getConvexHull(i));
                    
                    long i2 = 0;
                    
                    ofPolyline cleanedPoly;
                    
                    for(int i = 0; i < convexHull.size(); i++) {
                        float angle =0;
                        angle= convexHull.getAngleAtIndex(i);
                        if (angle > 15)
                            cleanedPoly.addVertex(convexHull[i]);
                    }
                    cleanedPoly.close();
                    
                    distlength.clear();
                    distlengthFinal.clear();
                    
                    
                    for(int i = 0; i < cleanedPoly.size(); i++) {
                        i2 = i+1;
                        if(i2 >= cleanedPoly.size()){
                            i2 = 0;
                        }
                        
                        
                        float dist = ofDist(cleanedPoly[i2].x,cleanedPoly[i2].y, cleanedPoly[i].x,cleanedPoly[i].y);
                        
                        
                        tester.first = dist;
                        tester.second = i;
                        
                        test.clear();
                        test.push_back(dist);
                        test.push_back(i);
                        test.push_back(i2);
                        
                        distlength.push_back(test);
                        
                        
                    }
                    
                    sort(distlength.begin(),distlength.end(), comparator);
                    
                    long sizecut = 0;
                    
                    if(distlength.size()>= 5)
                    {
                        sizecut = distlength.size() -5;
                    }
                    else{
                        sizecut = distlength.size();
                    }
                    
                    
                    
                    finalSquare.clear();
                    
                    disFin.clear();
                    
                    for(long i = distlength.size()-1; i > sizecut; i--) {
                        
                        test.clear();
                        test.push_back(distlength[i][0]);
                        test.push_back(distlength[i][1]);
                        test.push_back(distlength[i][2]);
                        disFin.push_back(test);
                        
                        
                    }
                    
                    sort(disFin.begin(),disFin.end(),comparator2);
                    
                    
                    for(int i = 0; i < disFin.size(); i++) {
                        
                        long ib = i+1;
                        if(ib>=disFin.size()){
                            ib =0;
                        }
                        
                        float x1 =  (cleanedPoly[disFin[i][2]].x-cleanedPoly[disFin[i][1]].x)*100;
                        float y2 = (cleanedPoly[disFin[i][2]].y-cleanedPoly[disFin[i][1]].y)*100;
                        
                        float x1b =  (cleanedPoly[disFin[ib][2]].x-cleanedPoly[disFin[ib][1]].x)*100;
                        float y2b = (cleanedPoly[disFin[ib][2]].y-cleanedPoly[disFin[ib][1]].y)*100;
                        
                        ofPoint A1,A2,B1,B2;
                        A1.set(cleanedPoly[disFin[i][1]].x-x1,cleanedPoly[disFin[i][1]].y-y2);
                        A2.set(cleanedPoly[disFin[i][2]].x +x1, cleanedPoly[disFin[i][2]].y+y2);
                        
                        B1.set(cleanedPoly[disFin[ib][1]].x-x1b,cleanedPoly[disFin[ib][1]].y-y2b);
                        B2.set(cleanedPoly[disFin[ib][2]].x +x1b, cleanedPoly[disFin[ib][2]].y+y2b);
                        
                        ofPoint finalpoint;
                        
                        
                        if( ofLineSegmentIntersection(A1, A2, B1,B2, finalpoint)){
                            
                            if(finalpoint.x >0 && finalpoint.x <W && finalpoint.y >0&& finalpoint.y <H)
                                finalSquare.addVertex(finalpoint);
                        }
                        
                    }
                    
                    
                    finalSquare.close();
                    
                    /* disAll.clear();
                     drawOrnot = true;
                     
                     for(int i= 0; i< finalSquare.size();i++){
                     
                     
                     i2 = i+1;
                     if(i2 >= finalSquare.size()){
                     i2 = 0;
                     }
                     
                     //  ofCircle(cleanedPoly[i], 4);
                     
                     disAll.push_back(ofDist(finalSquare[i2].x,finalSquare[i2].y, finalSquare[i].x,finalSquare[i].y));
                     
                     
                     
                     
                     float tempAngle = finalSquare.getAngleAtIndex(i);
                     if(tempAngle >99 || tempAngle <81){
                     
                     // better check the length of the sides instead of the angles.
                     
                     drawOrnot = false;
                     }
                     
                     if(finalSquare[i].x<5 || finalSquare[i].y<5 || finalSquare[i].x>635 || finalSquare[i].y>475)
                     {
                     drawOrnot = false;
                     }
                     
                     }
                     
                     sort(disAll.begin(),disAll.end());
                     if(disAll.size()>2)
                     if(disAll[disAll.size()-1]- disAll[0]>200){
                     drawOrnot = false;
                     }
                     
                     
                     
                     if(disAll.size()<4){
                     drawOrnot = false;
                     }
                     
                     
                     */
                    
                    
                    
                    drawOrnot = false;
                    
                    if(finalSquare.size() == 4){
                        long nrS = 10;
                        if(finalSquare[0].x>nrS && finalSquare[0].y>nrS && finalSquare[0].x<(W-nrS) && finalSquare[0].y<(H-nrS) &&
                           finalSquare[1].x>nrS && finalSquare[1].y>nrS && finalSquare[1].x<(W-nrS) && finalSquare[1].y<(H-nrS) &&
                           finalSquare[2].x>nrS && finalSquare[2].y>nrS && finalSquare[2].x<(W-nrS) && finalSquare[2].y<(H-nrS) &&
                           finalSquare[3].x>nrS && finalSquare[3].y>nrS && finalSquare[3].x<(W-nrS) && finalSquare[3].y<(H-nrS))
                        {
                            
                            float a = finalSquare.getAngleAtIndex(0);
                            float b = finalSquare.getAngleAtIndex(1);
                            float c = finalSquare.getAngleAtIndex(2);
                            float d = finalSquare.getAngleAtIndex(3);
                            
                            
                            float A = ofDistSquared(finalSquare[0].x,finalSquare[0].y, finalSquare[1].x, finalSquare[1].y);
                            float B = ofDistSquared(finalSquare[1].x,finalSquare[1].y, finalSquare[2].x, finalSquare[2].y);
                            float C = ofDistSquared(finalSquare[2].x,finalSquare[2].y, finalSquare[3].x, finalSquare[3].y);
                            float D = ofDistSquared(finalSquare[3].x,finalSquare[3].y, finalSquare[0].x, finalSquare[0].y);
                            
                            float vR = (a+c)/(b+d);
                            float dR =(A+C)/(B+D) ;
                            
                            if(vR < 2 && vR> 0 && dR < 2 && dR > 0 ){
                                drawOrnot = true;
                                
                                
                                
                                if(drawOrnot){
                                    drawOrnot = false;
                                    // ofSetColor(0,255,0);
                                    
                                    //ofSetColor(190,255,255);
                                    //ofFill();
                                    finalSquare.draw();
                                    
                                    finalVisual =finalSquare;
                                    // ofSetColor(0,255,0);
                                    // finalSquare.draw();
                                    
                                    /*  for(int i= 0; i< finalSquare.size();i++){
                                     //     ofCircle(finalSquare[i], 20);
                                     }*/
                                    
                                    
                                    
                                    
                                    if(finalSquare.size() >= 4) {
                                        vector<Point2f> srcPoints, dstPoints;
                                        for(int i = 0; i < finalSquare.size(); i++) {
                                            
                                            if(i == 1)
                                                dstPoints.push_back(Point2f(0, 0));
                                            
                                            if(i == 0)
                                                dstPoints.push_back(Point2f(0, HS));
                                            
                                            if(i == 3)
                                                dstPoints.push_back(Point2f(HS, HS));
                                            
                                            if(i == 2)
                                                dstPoints.push_back(Point2f(HS, 0));
                                            
                                            
                                            srcPoints.push_back(Point2f(int(finalSquare[i].x), int(finalSquare[i].y)));
                                            
                                            
                                        }
                                        
                                        // ofLog() << "dest: " << dstPoints;
                                        
                                        //   ofLog() << "src: " << srcPoints;
                                        
                                        homography = findHomography(Mat(srcPoints), Mat(dstPoints));
                                        homographyReady = true;
                                        if(homographyReady) {
                                            // this is how you warp one ofImage into another ofImage given the homography matrix
                                            // CV INTER NN is 113 fps, CV_INTER_LINEAR is 93 fps
                                            warpPerspective(workImage, workImageTrans, homography, CV_INTER_LINEAR);
                                            
                                            //warpPerspective(<#S &src#>, <#D &dst#>, <#vector<Point2f> &dstPoints#>)
                                            
                                            
                                            fbo.end();
                                            fbo3.begin();
                                            
                                            
                                            //   ofSetColor(255,255,255);
                                            threshold(workImageTrans, 127);
                                            // Canny(workImageTrans, workImageTrans, 12, 127, 3);
                                            //  threshold(workImageTrans, 127);
                                            
                                            workImageTrans.update();
                                            // contourFinder2.setThreshold(127);
                                            // contourFinder2.findContours(workImageTrans);
                                            
                                            //   reduce reduce the images collum and row
                                            // reduce(<#InputArray src#>, <#OutputArray dst#>, <#int dim#>, <#int rtype#>)
                                            
                                       
                                            
                                          //xxx//    workImageTrans.draw(0, 0);
                                          
                                            /* img.setFromPixels(workImageTrans.getPixels(), H, H, OF_IMAGE_GRAYSCALE);
                                             
                                             img.draw(0, 0,H/2,H/2);*/
                                            
                                            
                                            // dst does not imitate src
                                            
                                            //void warpPerspective(S& src, D& dst, Mat& transform, long flags = INTER_LINEAR) {
                                            /*       Mat srcMat = toCv(workImage), dstMat = toCv(workImageTrans);
                                             warpPerspective(srcMat, dstMat, homography, dstMat.size(), CV_INTER_LINEAR);
                                             //  }
                                             
                                             threshold(dstMat,dstMat, 127, false);
                                             
                                             
                                             // means of column test
                                             
                                             Mat mat =dstMat;
                                             Mat rowMat(mat.rows, 1, mat.type());
                                             for(int i = 0; i < mat.rows; i++) {
                                             rowMat.row(i) = mean(mat.row(i));
                                             }       */
                                            
                          
                                            
                                      
                                            
                                          //  columnMean = meanRows(workImageTrans);
                                            //columnMean =rowMat;
                                            
                                            
                                                  cv::Mat mat =   toCv(workImageTrans);
                                              cv::Mat  columnMean(mat.rows, 3, CV_8UC1);
                                             cv::Mat  rowMean(mat.cols, 3, CV_8UC1);
                                            
                                                for(int i = 0; i < mat.rows; i++) {
                                                    columnMean.row(i) = mean(mat.row(i));
                                                }
                                            
                                            
                                            for(int i = 0; i < mat.cols; i++) {
                                                rowMean.row(i) = mean(mat.col(i));
                                            }
                                            
                                            
                                            
                               
                                         //   rowMean = meanCols(workImageTrans);
                                            
                                            
                    
                                            
                                            long arraySize = HS;
                                            
                                            long colm[arraySize];
                                            long row[arraySize];
                                            
                                    
                                            
                       
                                            for(int i = 0; i < columnMean.rows; i++) {
                                                colm[i] = columnMean.at<Vec3b>(i)[0];
                                            }
                      
                                            
                                  
                                            
                                            
                                            
                                            
                                            for(int i = 0; i < arraySize; i++) {
                                                row[i] = rowMean.at<Vec3b>(i)[1];
                                                
                                            }
                                            
                                            long colmMin = 0, colmMax = 0;
                                            long rowMin = 0, rowMax = 0;
                                            long colmHigh =0, rowHigh = 0;
                                            long colmCount = 0, rowCount = 0;
                                            
                                            //int flipby90 = 0;
                                            long sensitiveEdge = 170;
                                            long edgeOfset = 1;
                                            
                                            long sensitiveCountSearch = 10;
                                            
                                            // define edges of the tag for colums
                                            // min
                                            for(int i = 1; i < arraySize ; i++) {
                                                if (colm[i]< sensitiveEdge){
                                                    colmMin = i+edgeOfset;
                                                    break;
                                                }
                                            }
                                            
                                            //max
                                            for(long i = arraySize; i > 0 ; i--) {
                                                if (colm[i]< sensitiveEdge && colm[i]>30){
                                                    colmMax = i+edgeOfset;
                                                    break;
                                                }
                                            }
                                            
                                            
                                            // define edges of the tag for rows
                                            // min
                                            for(int i = 1; i < arraySize ; i++) {
                                                if (row[i]< sensitiveEdge){
                                                    rowMin = i+edgeOfset;
                                                    break;
                                                }
                                            }
                                            
                                            //max
                                            for(long i = arraySize; i > 0 ; i--) {
                                                if (row[i]< sensitiveEdge && row[i]>30){
                                                    rowMax = i+edgeOfset;
                                                    break;
                                                }
                                            }
                                            
                                            // search the highest value colm
                                            for(long i = colmMin+5; i < colmMax-5 ; i++) {
                                                if (colm[i]> colmHigh)
                                                    colmHigh = colm[i];
                                            }
                                            
                                            // search the highest value row
                                            for(long i = rowMin+5; i < rowMax-5 ; i++) {
                                                if (row[i]> rowHigh)
                                                    rowHigh = row[i];
                                            }
                                            
                                            
                                            
                                            
                                            // here goes the rotation
                                            
                                            if(rowHigh>colmHigh){
                                                workImageTrans.rotate90(1);
                                                
                                                
                                                long placeholder = 0;
                                                
                                                placeholder =colmMin;
                                                colmMin = rowMin;
                                                rowMin = placeholder;
                                                
                                                placeholder =colmMax;
                                                colmMax = rowMax;
                                                rowMax = placeholder;
                                                
                                                placeholder =colmHigh;
                                                colmHigh = rowHigh;
                                                rowHigh = placeholder;
                                                
                                                placeholder =colmCount;
                                                colmCount = rowCount;
                                                rowCount = placeholder;
                                                
                                                for(int i = 0; i < arraySize ; i++) {
                                                    placeholder = colm[i];
                                                    colm[i] = row[i];
                                                    row[i] = placeholder;
                                                }
                                            }
                                            
                                            
                                            
                                          //xxx//    workImageTrans.draw(0, 0);
                                            
                                            
                                            bool oldValue = false;
                                            bool newValue = false;
                                            
                                            
                                            // search for amount of colums
                                            for(long i = colmMin+5; i < colmMax-5 ; i+=3) {
                                                if (colm[i]> colmHigh-sensitiveCountSearch){
                                                    newValue = true;
                                                }else{
                                                    newValue = false;
                                                }
                                                
                                                if(oldValue != newValue){
                                                    colmCount++;
                                                }
                                                
                                                oldValue = newValue;
                                            }
                                            colmCount = colmCount/2;
                                            
                                            
                                            oldValue = false;
                                            newValue = false;
                                            
                                            // search for amount of rows
                                            for(long i = rowMin+5; i < rowMax-5 ; i+=3) {
                                                if (row[i]> rowHigh-sensitiveCountSearch){
                                                    newValue = true;
                                                }else{
                                                    newValue = false;
                                                }
                                                
                                                if(oldValue != newValue){
                                                    rowCount++;
                                                }
                                                
                                                oldValue = newValue;
                                            }
                                            rowCount = rowCount/2;
                                            
                                            
                                            long blockCount = (colmCount*8)+7;
                                            
                                            //   ofLog() << blockCount;
                                            
                                            
                                            float blockSizeX = float(colmMax-colmMin)/float(blockCount);
                                            float blockSizeY = float(rowMax-rowMin)/float(blockCount);
                                            
                                            //   ofLog() << blockSizeX;
                                            
                                            //int ArraySize = blockCount*blockCount;
                                            
                                            bool imageData[blockCount][blockCount];
                                            
                                            
                                            
                                            pixels = workImageTrans.getPixels();
                                            
                                     
                                            long halfBlock = blockSizeX/2;
                                            
                                            for(int i = 0; i < blockCount; i++) {
                                                
                                                for(int k = 0; k < blockCount; k++) {
                                                    
                                                    int X = colmMin+((blockSizeX*i)+(halfBlock));
                                                    int Y = rowMin+((blockSizeY*k)+(halfBlock));
                                                    
                                                    if(X>HS) X = HS;
                                                    if(Y>HS) Y = HS;
                                                    
                                                    if(pixels.getColor(X, Y)[0] > 100){
                                                        
                                                        imageData[i][k] = true;
                                                    }else{
                                                      
                                                        imageData[i][k] = false;
                                                    }
                                                }
                                            }
                                            
                                            
                                            // check if the image is correct located
                                            
                                            
                                            
                                           // workImageTrans.draw(0, 0);
                                            

                                            
                                            for(int a = 0; a < (colmCount+1); a++) {
                                                for(int b = 0; b < ((colmCount+1)*2); b++) {
                                                    
                                                    bool bitLetter[21];
                                                    long countBit = 0;
                                                    
                                                    for(int c = 0; c < 3; c++) {
                                                        for(int d = 0; d < 7; d++) {
                                                            
                                                            long x = b*4 + c;
                                                            long y = a*8 + d;
                                                            
                                                            // ofLog() << "x: " << x << " y: " << y;
                                                            if(imageData[x][y]){
                                                                bitLetter[countBit] = false;
                                                            }else{
                                                                bitLetter[countBit] = true;
                                                            }
                                                            
                                                            
                                                            countBit++;
                                                        }
                                                    }
                                                    
                                                    string debugs = "";
                                                    
                                                    for(int i = 0; i < 21; i++) {
                                                        
                                                        debugs+= ofToString(bitLetter[i]);
                                                    }
                                                    
                                                    //   ofLog() << debugs;
                                                    
                                                    // here is a letter filled
                                                    
                                                    long resBitNumber = bitNumber(bitLetter);
                                                    
                                                    if(resBitNumber == 912127)
                                                    {
                                                        
                                                        workImageTrans.rotate90(2);
                                                        
                                                        workImageTrans.update();
                                                        
                                                      
                                                        
                                               
                                                        
                                                        pixels = workImageTrans.getPixels();
                                                    
                                                        
                                                        for(int i = 0; i < blockCount; i++) {
                                                            
                                                            
                                                            for(int k = 0; k < blockCount; k++) {
                                                                
                                                                 ofRect(colmMin,rowMin,blockSizeX,blockSizeY);
                                                                
                                                                long X = colmMin+((blockSizeX*i)+(blockSizeX/2));
                                                                long Y = rowMin+((blockSizeY*k)+(blockSizeX/2));
                                                                   ofSetColor(ofColor::green);
                                                                 ofRect(X,Y,1,1);
                                                                
                                                                if(X>HS) X = HS;
                                                                if(Y>HS) Y = HS;
                                                                
                                                                
                                                                //if( pixels[Y*(X+1)] > 100){
                                                                
                                                                if(pixels.getColor(X, Y)[0] > 100){
                                                                    imageData[i][k] = true;
                                                                }else{
                                                                    imageData[i][k] = false;
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        break; break;break;
                                                    }
                                                    
                                                    
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            
                                           /*
                                            
                                             for(int i = 0; i < blockCount; i++) {
                                             
                                             
                                             for(int k = 0; k < blockCount; k++) {
                                             
                                             if(imageData[i][k] != true){
                                          
                                             ofFill();
                                             }else{
                                               
                                             ofNoFill();
                                             }
                                             
                                                  ofSetColor(ofColor::green);
                                                ofDrawRectangle(colmMin+(blockSizeX*i),rowMin+(blockSizeY*k),blockSizeX,blockSizeY);
                                             
                                             }
                                             }*/
                                           
                                            fbo3.end();
                                            
                                            fbo.begin();
                                            
                                            // if the image is not in the right size we should flip it here and now
                                            // we also flip the calculations above so that we can use the right calculations
                                            
                                            
                                            // ofLog() << "new frame";
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            // here we start writing all the magic analyzing the text and creating the result
                                            
                                            
                                            // try {
                                            
                                            theMessage = "";
                                            
                                            // ofLog() << "new frame";
                                            
                                            for(int a = 0; a < (colmCount+1); a++) {
                                                
                                                
                                                for(int b = 0; b < ((colmCount+1)*2); b++) {
                                                    
                                                    
                                                    
                                                    bool bitLetter[21];
                                                    bool bitSpacer[21];
                                                    long countBit = 0;
                                                    
                                                    long countSpaceBit = 0;
                                                    
                                                    for(int c = 0; c < 3; c++) {
                                                        for(int d = 0; d < 7; d++) {
                                                            
                                                            long x = b*4 + c;
                                                            long y = a*8 + d;
                                                            
                                                            // ofLog() << "x: " << x << " y: " << y;
                                                            if(imageData[x][y]){
                                                                bitLetter[countBit] = false;
                                                            }else{
                                                                bitLetter[countBit] = true;
                                                            }
                                                            
                                                            bitSpacer[countBit] = false;
                                                            
                                                            countBit++;
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    for(int e = 0; e < 7; e++) {
                                                        
                                                        long x = b*4 + 3;
                                                        long y = a*8 + e;
                                                        
                                                        if(b< ((colmCount+1)*2)-1){
                                                            
                                                            if(imageData[x][y]){
                                                                bitSpacer[countSpaceBit] = false;
                                                            }else{
                                                                bitSpacer[countSpaceBit] = true;
                                                            }
                                                            
                                                            
                                                            
                                                        }else{
                                                            x = b*4;
                                                            y = a*8 + 7;
                                                            
                                                            
                                                            if(!imageData[x][y]){
                                                                bitSpacer[countSpaceBit] = true;
                                                            }
                                                            x++;
                                                            if(!imageData[x][y]){
                                                                bitSpacer[countSpaceBit] = true;
                                                            }
                                                            x++;
                                                            if(!imageData[x][y]){
                                                                bitSpacer[countSpaceBit] = true;
                                                            }
                                                            
                                                            
                                                            
                                                        }
                                                        
                                                        countSpaceBit++;
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                    string debugs = "";
                                                    
                                                    for(int i = 0; i < 21; i++) {
                                                        
                                                        debugs+= ofToString(bitLetter[i]);
                                                    }
                                                    
                                                    //   ofLog() << debugs;
                                                    
                                                    // here is a letter filled
                                                    
                                                    long resBitNumber = bitNumber(bitLetter);
                                                    
                                                    
                                                    for(int i = 0; i < 136; i++) {
                                                        if(resBitNumber == intA[i]){
                                                            
                                                            // now we have the number
                                                            
                                                            theMessage += charA[i];
                                                            break;
                                                            
                                                        }
                                                    }
                                                    
                                                    long resBitSpacer = bitNumber(bitSpacer);
                                                    
                                                    // ofLog () <<bitSpacer;
                                                    //  ofLog () << "sp: " << resBitSpacer;
                                                    if(resBitSpacer == 0){
                                                        theMessage += " ";
                                                    }
                                                    
                                                    
                                                }
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                //   ofSetColor(255,0,0);
                                
                                
                                
                                
                                
                                
                                //verdana30.drawString(theMSG, 30, 30);
                                
                                //ofDrawBitmapString(theMSG, 30, 30);
                                
                                
                            }
                            
                        }
                    }
                }
                
                
            }
            
            
            //  ofLog() << theMessage;
            
            long endBlock = theMessage.find_last_of(" & ");
            
            // long checkBlock = theMessage.find_last_of("&", endBlock-1);
            
            if(endBlock >=0){
                // string finalMessage = theMessage.substr (0, endBlock);
                // string checkMSG = theMessage.substr (endBlock+1, 3);
                
                string finalMessage = theMessage.substr (0, endBlock-2);
                string checkMSG = theMessage.substr (endBlock+1, 3);
                
                //   ofLog() << "calculated: " <<itob62(crc16(finalMessage.c_str(), finalMessage.size()));
                
                // ofLog() << "number   : " <<crc16(finalMessage.c_str(), finalMessage.size());
                
                
                // ofLog() << "theMessage  : " << theMessage;
                
                //   ofLog() << "message  : " << checkMSG;
                
                //    ofLog() << "finalMessage  : " << finalMessage;
                
                //  long MSGCheckSumm = crc32(finalMessage.c_str(), finalMessage.size());
                
                
                
                
                string strcheckMSG="";
                
                string testCheck = ".";
                
                
                size_t foundPoint = checkMSG.find(testCheck);
                
                if(foundPoint == 0){
                    checkMSG.erase(0,1);
                }
                
                size_t foundPoint2 = checkMSG.find(testCheck);
                
                if(foundPoint2 == 0){
                    checkMSG.erase(0,1);
                }
                
                
                
                
                //    ofLog() << checkMSG;
                
                
                
                unsigned short  MSGCheckSumm = crc16(finalMessage.c_str(), finalMessage.size());
                
                
                
                //  ofLog() << MSGCheckSumm << " >>" << finalMessage << "<< " <<  itob62(MSGCheckSumm) << ":" << checkMSG;
                
                if(finalcount>0){
                    ofPath p = ofPath();
                    p.setStrokeColor(ofColor(0,255,255));
                    p.setFilled(true);
                    p.setStrokeWidth(5);
                    p.setFillColor(ofColor(0,255,255,40));
                    p.moveTo(finalVisual[0]);
                    p.lineTo(finalVisual[1]);
                    p.lineTo(finalVisual[2]);
                    p.lineTo(finalVisual[3]);
                    p.close();
                    p.draw();
                    
                    
                    
                    //  finalVisual.draw();
                    
                }
                
                ofSetLineWidth(5);
                if(itob62(MSGCheckSumm) ==checkMSG){
                    
                    
                    
                    //   ofLog() << theMessage << " endBlock: " << endBlock << " check Block: " << checkBlock << "count: " << messageCounter;
                    
                    //  messageCounter++;
                    
                    theMSG = finalMessage;
                    
              //       ofLog() << "msg: " << finalMessage;
                    
                    //  ofLog() << "check: " << checkMSG << " : " << itob32(MSGCheckSumm);
                    
                    if(finalMessage !=messageOld){
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        finalcount = 5;
                    }
                    
                    
                    string str2 ("http://");
                    string str3 ("https://");
                        string str4 ("coin://");
                    
                    size_t found1 = finalMessage.find(str2);
                    
                    size_t found2 = finalMessage.find(str3);
                    
                     size_t found3 = finalMessage.find(str4);
                    
                    
                    if(found3 ==0){
                        
                       string finalMessage2 = "https://blockchain.info/address/" +finalMessage.substr (7);
                        
                        ofLog() << "this is:" << finalMessage2;
                        
                     NSURL *nsURL = [NSURL URLWithString:[NSString stringWithCString:finalMessage2.c_str() encoding:[NSString defaultCStringEncoding]]];
                        
                        [[UIApplication sharedApplication] openURL:nsURL];
                    }
                    
                    if(found2 ==0){
                        NSURL *nsURL = [NSURL URLWithString:[NSString stringWithCString:finalMessage.c_str() encoding:[NSString defaultCStringEncoding]]];
                        
                        [[UIApplication sharedApplication] openURL:nsURL];
                    }
                    
                    if(found1 ==0){
                        
                        //  ofLog() << finalMessage;
                        
                        if(setWebLocal){
                            
                            
                            interface.deactivateView();
                            // interface.loadLocalFile("setup","page");
                            
                            interface.loadURL(finalMessage.c_str());
                            interface.activateView();
                            
                            interfaceActivity = 3;
                            finalMessage = "";
                            checkMSG = "";
                            theMessage = "";
                            messageOld = " ";
                            
                        }else{
                            
                            
                            NSURL *nsURL = [NSURL URLWithString:[NSString stringWithCString:finalMessage.c_str() encoding:[NSString defaultCStringEncoding]]];
                            
                            [[UIApplication sharedApplication] openURL:nsURL];
                            
                        }
                        
                    }
                    else{
                        
                        // send data to webapge
                        
                        
                        if(finalMessage !=messageOld){
                            interface.deactivateView();
                            // interface.loadLocalFile("setup","page");
                            
                            interface.loadLocalFile("textMessage","page");
                            
                            
                            interface.activateView();
                            
                            interfaceActivity = 4;
                            
                            webText = finalMessage;
                        }
                        
                    }
                    
                    messageOld =finalMessage;
                    
                    
                    
                }
                
            }
            
            
            ofSetColor(255);
            
        }
        
        
        
  
        
        
        
        fbo.end();
        
        //fbo.draw(0,(ofGetHeight()-(ofGetWidth()*0.75))/2,ofGetWidth(),ofGetWidth()*0.75);
        
        //  fbo.draw(0,(ofGetWidth()-(ofGetHeight()*1.333))/2,ofGetHeight(),ofGetHeight()*1.333);
        fbo.draw(0,0 ,ofGetHeight(),ofGetHeight()*1.333);
        
       //    fbo3.draw(0,0 ,HS,HS);
        //  ofSetColor(255);
        
        
        

        
        if(finalcount>0){
            finalcount--;
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    if(abcRect.inside(touchPoint) && interfaceActivity != 1){
        interface.deactivateView();
        interface.loadLocalFile("abc","page");
        interface.activateView();
        
        interfaceActivity = 1;
    }
    
    if(setRect.inside(touchPoint) && interfaceActivity != 2){
        interface.deactivateView();
        interface.loadLocalFile("setup","page");
        interface.activateView();
        
        interfaceActivity = 2;
    }
    
    
    if(interfaceActivity !=0){
        
        
        
        backImg.draw(backRect);
        
        
        if(backRect.inside(touchPoint) && interfaceActivity != 0){
            interface.deactivateView();
            interface.loadLocalFile("dummy","page");
            interface.activateView();
            
            interfaceActivity = 0;
            
            messageOld = "";
        }
        
        
    }
    
    abcImg.draw(abcRect);
    setImg.draw(setRect);
    
    
    
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    touchPoint.x =touch.x;
    touchPoint.y =touch.y;
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    touchPoint.x =touch.x;
    touchPoint.y =touch.y;
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    touchPoint.x = -1;
    touchPoint.y = -1;
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
    // ofLog() <<newOrientation;
    
    /*  if(ofGetOrientation() == OF_ORIENTATION_90_RIGHT){
     ofxiPhoneSetOrientation( OF_ORIENTATION_90_RIGHT);
     }
     
     if(ofGetOrientation() == OF_ORIENTATION_90_LEFT){
     ofxiPhoneSetOrientation( OF_ORIENTATION_90_LEFT);
     }
     */
    
}

/*
 void ofApp::cons(){
 ofLog() << ">>cons";
 for(int i =0;i<angleCollector.size();i++){
 ofLog() << i << " " << angleCollector[i].x << " " << angleCollector[i].y;
 }
 }
 */

/*-
 *  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or
 *  code or tables extracted from it, as desired without restriction.
 *
 *  First, the polynomial itself and its table of feedback terms.  The
 *  polynomial is
 *  X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0
 *
 *  Note that we take it "backwards" and put the highest-order term in
 *  the lowest-order bit.  The X^32 term is "implied"; the LSB is the
 *  X^31 term, etc.  The X^0 term (usually shown as "+1") results in
 *  the MSB being 1
 *
 *  Note that the usual hardware shift register implementation, which
 *  is what we're using (we're merely optimizing it by doing eight-bit
 *  chunks at a time) shifts bits into the lowest-order term.  In our
 *  implementation, that means shifting towards the right.  Why do we
 *  do it this way?  Because the calculated CRC must be transmitted in
 *  order from highest-order term to lowest-order term.  UARTs transmit
 *  characters in order from LSB to MSB.  By storing the CRC this way
 *  we hand it to the UART in the order low-byte to high-byte; the UART
 *  sends each low-bit to hight-bit; and the result is transmission bit
 *  by bit from highest- to lowest-order term without requiring any bit
 *  shuffling on our part.  Reception works similarly
 *
 *  The feedback terms table consists of 256, 32-bit entries.  Notes
 *
 *      The table can be generated at runtime if desired; code to do so
 *      is shown later.  It might not be obvious, but the feedback
 *      terms simply represent the results of eight shift/xor opera
 *      tions for all combinations of data and CRC register values
 *
 *      The values must be right-shifted by eight bits by the "updcrc
 *      logic; the shift must be unsigned (bring in zeroes).  On some
 *      hardware you could probably optimize the shift in assembler by
 *      using byte-swap instructions
 *      polynomial $edb88320
 *
 *
 * CRC32 code derived from work by Gary S. Brown.
 */



static uint32_t crc32Lookup[] = {
    0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
    0xe963a535, 0x9e6495a3,	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
    0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
    0xf3b97148, 0x84be41de,	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
    0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,	0x14015c4f, 0x63066cd9,
    0xfa0f3d63, 0x8d080df5,	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
    0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,	0x35b5a8fa, 0x42b2986c,
    0xdbbbc9d6, 0xacbcf940,	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
    0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
    0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
    0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,	0x76dc4190, 0x01db7106,
    0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
    0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
    0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
    0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
    0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
    0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
    0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
    0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
    0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
    0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
    0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
    0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
    0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
    0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
    0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
    0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
    0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
    0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
    0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
    0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
    0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
    0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
    0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
    0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
    0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
    0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
    0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
    0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
    0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
    0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
    0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
    0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
};
/*
 
 uint32_t ofApp::crc32(const unsigned char *buf, size_t size)
 {
 uint32_t crc = 0;
 
 const uint8_t *p;
 
 p = buf;
 crc = crc ^ ~0U;
 
 while (size--)
 crc = crc32_tab[(crc ^ *p++) & 0xFF] ^ (crc >> 8);
 
 return crc ^ ~0U;
 }*/

int32_t ofApp::crc32(const void* data, size_t length)
{
    uint32_t previousCrc32 = 0;
    
    uint32_t crc = ~previousCrc32;
    unsigned char* current = (unsigned char*) data;
    while (length--)
        crc = (crc >> 8) ^ crc32Lookup[(crc & 0xFF) ^ *current++];
    return ~crc;
}


string ofApp::itob32( long i )
{
    unsigned long u = *reinterpret_cast<unsigned long*>( &i ) ;
    std::string b32 ;
    
    do
    {
        long d = u % 32 ;
        if( d < 10 )
        {
            b32.insert( 0, 1, '0' + d ) ;
        }
        else
        {
            b32.insert( 0, 1, 'a' + d - 10 ) ;
        }
        
        u /= 32 ;
        
    } while( u > 0 );
    
    return b32 ;
}


string ofApp::itob62( long i )
{
    unsigned long u = *reinterpret_cast<unsigned long*>( &i ) ;
    std::string b32 ;
    
    do
    {
        long d = u % 62 ;
        if( d < 10 )
        {
            b32.insert( 0, 1, '0' + d ) ;
        }
        else if (d < 36)
        {
            b32.insert( 0, 1, 'a' + d - 10 ) ;
        }
        else
        {
            b32.insert( 0, 1, 'A' + d - 36 ) ;
        }
        
        u /= 62 ;
        
    } while( u > 0 );
    
    return b32 ;
}


long ofApp::bitNumber (bool bits[21]){
    long bitResult;
    
    for(int i = 0; i<32;i++){
        bitResult &= ~(1 << i);
    }
    
    for(int i = 0; i<20;i++){
        if(bits[i]){
            bitResult |= 1 << i;
        }else{
            bitResult &= ~(1 << i);
        }
    }
    return bitResult;
}


static unsigned short crc_table [256] = {
    
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5,
    0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b,
    0xc18c, 0xd1ad, 0xe1ce, 0xf1ef, 0x1231, 0x0210,
    0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
    0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c,
    0xf3ff, 0xe3de, 0x2462, 0x3443, 0x0420, 0x1401,
    0x64e6, 0x74c7, 0x44a4, 0x5485, 0xa56a, 0xb54b,
    0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6,
    0x5695, 0x46b4, 0xb75b, 0xa77a, 0x9719, 0x8738,
    0xf7df, 0xe7fe, 0xd79d, 0xc7bc, 0x48c4, 0x58e5,
    0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969,
    0xa90a, 0xb92b, 0x5af5, 0x4ad4, 0x7ab7, 0x6a96,
    0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc,
    0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
    0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03,
    0x0c60, 0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd,
    0xad2a, 0xbd0b, 0x8d68, 0x9d49, 0x7e97, 0x6eb6,
    0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
    0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a,
    0x9f59, 0x8f78, 0x9188, 0x81a9, 0xb1ca, 0xa1eb,
    0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1,
    0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c,
    0xe37f, 0xf35e, 0x02b1, 0x1290, 0x22f3, 0x32d2,
    0x4235, 0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb,
    0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
    0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447,
    0x5424, 0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8,
    0xe75f, 0xf77e, 0xc71d, 0xd73c, 0x26d3, 0x36f2,
    0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9,
    0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827,
    0x18c0, 0x08e1, 0x3882, 0x28a3, 0xcb7d, 0xdb5c,
    0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
    0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0,
    0x2ab3, 0x3a92, 0xfd2e, 0xed0f, 0xdd6c, 0xcd4d,
    0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07,
    0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
    0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba,
    0x8fd9, 0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74,
    0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
};

unsigned long ofApp::crc16(const void *dataIn, size_t length)
{
    
    
    unsigned short  seed = 0xffff;
    unsigned short final = 0;
    
    size_t count;
    unsigned long crc = seed;
    unsigned long temp;
    
    unsigned char* data = (unsigned char*) dataIn;
    
    for (count = 0; count < length; ++count)
    {
        temp = (*data++ ^ (crc >> 8)) & 0xff;
        crc = crc_table[temp] ^ (crc << 8);
    }
    
    return (unsigned long)(crc ^ final);
    
}

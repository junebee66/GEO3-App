# GEO3-App
<img src="https://github.com/junebee66/molab-2023/blob/main/Week11/Sources/MU_Outdoor.jpg" width="100%">
GEO3 is an IOS mobile app that provides a cloud paltform for sharing sptial videos and trade geospatial data. 
Spatial video is the next media format after .mp4 videos. In this app you can record videos in 3D orientation, 
view other's intriguiing 3D videos, 
and trade your video as either geospatial data 
or or motion data for machine training purposes. 
I planned to futther develop this after class.

### **🛑 DISCLAIMER 🛑**
⚫️ This app is currently under development functions may run into issues, feel free to update issues in repo</br>
⚫️ The documentation is still work in progress
⚫️ Talk about functions first then the problems encounter.

<img src="https://github.com/junebee66/molab-2023/blob/main/Week11/Sources/GEO3_Feature_noLogo.png" width="100%">

## **🫱 How to Use?**
Once you turn on this software on your mobile devices (phones, or tablets), you will be asked to login to your Google account. Once you're logged in, you will be landing the main view of the app. On the bottom there's 4 buttons to switch around the 4 different functions of the app: Scan, Gallery, Map, and Setting. They are placed in the potential usage order. Once you scan, you are able to see all your spatial video in the gallery view. If you want to share your spatial video to the world, you can add them to the map and also view other's spatial video on the map. Furthermore, if you're more interested in trading your assets you can also put the video on bid.

### **🛠️ Functionality**

**1️⃣ Scan Video Capure**</br>
>[📀 Code Here](https://github.com/junebee66/AVR-Filter/weglAnaglyph/youtube.html)</br>
> In this view you are able to record vidoes in 3D - sptial video. 
In the current version,only static 3D models are captured. The animating 3D models will be updated. </br>
<img src="https://github.com/junebee66/molab-2023/raw/main/Week06/source/export.gif" width="30%">

</br>

**2️⃣ Model View**
>[📀 Code Here](https://github.com/)
> In this view you can view the model you just created
and be able to change its texture with the AI integration.
<img src="https://github.com/junebee66/molab-2023/raw/main/Week08/source/sand.gif" width="30%">


**2️⃣ Gallery View**</br>
>[📀 Code Here](https://github.com/junebee66/AVR-Filter/weglAnaglyph/youtube.html)</br>
> In this view, you are able to view all spatial video you have recorded in the past and also change its texture with ai.
<img src="https://github.com/junebee66/molab-2023/raw/main/Week11/Sources/ModelViews.gif" width="30%">
<img src="https://github.com/junebee66/molab-2023/raw/main/Week11/Sources/slidegif.gif" width="30%">


**3️⃣ Map View**</br>
>[📀 Code Here](https://github.com/junebee66/AVR-Filter/weglAnaglyph/youtube.html)</br>
> This is a virtual 3D scene with a YouTube UI Mockup. The color of the scene is distorted with the Anaglyph Effect, so users are able to see a 3D UI when they wear Anaglyph glasses </br>
<img src="https://github.com/junebee66/molab-2023/raw/main/Week11/Sources/3DMap_Short_1.gif" width="30%">
</br>


**4️⃣ Setting View**</br>
>[📀 Code here](https://github.com/junebee66/AVR-Filter/weglAnaglyph/youtube.html)</br>
> This page shows all settings related to your google account and you can also make changes here. By signing into Google, you already create an account in this app.</br>
<img src="https://github.com/junebee66/molab-2023/raw/main/Week09/source/particle.gif" width="30%">
</br>

## **🛠️ Things I learned in This Project**
1. Functionality and UI is comletely different. I should not try to code them at the same time.
2. I really enjoy the coding sessions with professor John Henry. I feel like when I'm coiding on my own and encounter an issue. I usually kept looking at it and keep thinking there's someting wrong with this. However, in the offic hour, when Professor JohnHenry looks at it, he can identify that it is a structue and communication problem between my files. I find that extremely useful.
3. 3D is hard. The way apple complie 3d object is very different than I used to work with, so even a little thing as assigning texture can be extremely complicated and indirect. This is my first time writing a pretty low level (close to backend code) this makes it very hard when I need to declare many detail settings. When the project gets larger, it is very hard to keep on track. 

## **🛑Challenges & Struggles**

**1. Scan and transfer Object**</br>
trying to sync up all the obj across the platform has been quite complicated because the the project is set up with multiple struct hierarchy. Professor John Henry helped me figured it out how to pass it from the scan to view model struct.
![scannedObj](https://github.com/junebee66/GEO3-App/assets/81065927/6967748b-f555-4c93-9eda-b294c5d7d88f)

**2. Complie texture with mld and mtl texture**</br>
This is where I spent the most time. Once I was able to pass the 3d model to viewing port, I realized the model doesn't have a texture. At first I thought it is because I didn't assign texture to it but later figure out that textue files are pretty messy 
<img width="440" alt="texture_issue" src="https://github.com/junebee66/GEO3-App/assets/81065927/ed9cc717-8f77-415c-8a97-e80fb4657dbd">

**3. swift doesn't read pooint cloud files**</br>

**3. Sync with Firebase**</br>

## **☁️ Future Development Envision**
**Map View Call Out**</br>
**3D model scan to point cloud**</br>

<img src="https://github.com/junebee66/molab-2023/raw/main//Week11/Sources/3DMap_Short.gif" width="70%">

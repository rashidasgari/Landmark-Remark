# Landmark-Remark
Tiger Spike iOS Developer Assignment

Description:
-	The project was coded in XCode 9.0.1
-	The app is optimized to work on iPhone 7 (as noted in the document) and iPhone 7+
-	I have only used FireBase 3rd party library. No other 3rd party libraries or classes have been used.
-	The sign-in and user authentication process was handled with Google Sign-in for the sake of simplicity.
Workflow:
-	The user is asked to sign-in using their Google account.
-	The user is navigated to the next scene which is the main map view.
-	All the remarks are displayed in this map view. The remarks made by the user themselves is displayed with a Blue pin icon and the rest are displayed with a Red pin icon.
-	Upon tapping on each pin the username and the remark is displayed.
-	A new remark can be added by tapping the (+) button on the bottom right of the screen.
-	The user can also search for a remark either by the authors name or the remark note.

Backend:
-	Since each user has to be able to view other users’ notes, I have used FireBase database. FireBase DB provides a No-SQL implementation that is synced in the cloud. The changes are easily pushed to the client. A sample snapshot of the DB schema:
{
  "remarks" : {
    "1" : {
      "dateTime" : "2017-10-24 03:51:02 +0000",
      "lat" : 1.337253,
      "long" : 103.757748,
      "remark" : "An amazing place to hangout. Nice atmosphere. Highly recommended!",
      "userName" : "rashid.asgari"
    },
    "2" : {
      "dateTime" : "2017-10-23 01:20:02 +0000",
      "lat" : 1.310784,
      "long" : 103.788091,
      "remark" : "The food is lovely. Would definitely come again.",
      "userName" : "ace.rothstein"
    },
    "3" : {
      "dateTime" : "2017-10-24 03:51:02 +0000",
      "lat" : 1.337253,
      "long" : 1.337253,
      "remark" : "hey!",
      "userName" : "hans.zimmer"
    },
    "-KxXTRY_FyGZVNv6S6RD" : {
      "dateTime" : "28.10.2017",
      "lat" : "1.324987",
      "long" : "103.825485",
      "remark" : "Hshchxvsbsb",
      "userName" : "rashid asgari"
    },
    "-KxZ2OStgzRb_vAVny-U" : {
      "dateTime" : "29.10.2017",
      "lat" : "1.325040",
      "long" : "103.825611",
      "remark" : "Come onnnnnn",
      "userName" : "rashid asgari"
    },
    "-KxaBZLmxBUotVToByf_" : {
      "dateTime" : "29.10.2017",
      "lat" : "1.325042",
      "long" : "103.825576",
      "remark" : "Yo yo digidgyy",
      "userName" : "rashid asgari"
    },
    "-KxbvDjhCLvOeZo9hYay" : {
      "dateTime" : "29.10.2017",
      "lat" : "1.255974",
      "long" : "103.821013",
      "remark" : "Had dinner at chillis resort world. Try the half ribs its yummy",
      "userName" : "rashid asgari"
    }
  }
}


Project management:
-	I have used Trello to document and manage the tasks. 
-	I broke down the user stories in the following order:
o	Locate User (3 man-hours)
♣	Description: As a user (of the application) I can see my current location on a map  
♣	Tasks:
¬	Setup project
¬	Setup firebase
¬	Setup google sign in
¬	Prepare storyboard
¬	Mapview and location methods
o	Save Remark (2 man-hours)
♣	Description: As a user I can save a short note at my current location  
♣	Tasks:
¬	Setup newRemarkView
¬	Save to FireBase
o	View Remarks (2 man-hours)
♣	Description: As a user I can see notes that I have saved at the location they were saved on the map  
♣	Description: As a user I can see the location, text, and user-name of notes other users have saved  
♣	Tasks:
¬	Read data from FireBase
o	Search Remarks (3 man-hours)
♣	Description: As a user I have the ability to search for a note based on contained text or user-name  
♣	Tasks:
¬	Setup search bar and methods
o	Debug and Document (2 man-hours)





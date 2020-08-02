//Base URL
const String Base_Url = "https://devcrimeapp.azurewebsites.net/api/";
const String Upload_Image_Url = Base_Url + "UploadFile/UploadFile";
const String Login_Url = Base_Url + "Login/Login";
const String Save_DeviceId_Url = Base_Url + "User/SaveDeviceId";
const String Update_Notification_Url =
    Base_Url + "PushNotifications/UpdateUserNotification";
const String Provider_Login_Url = Base_Url + "Login/Providerlogin";
const String CreateMarkerDetails_Url =
    Base_Url + "PushNotifications/CreateMarkerDetails";
const String Generate_Otp_Url = Base_Url + 'User/generateOTP';
const String SignUp_Url = Base_Url + "User/User";
const String Otp_Verify_Url = Base_Url + 'User/OTPVerify';
const String Active_Crime_Url = Base_Url + "Crime/Crimes";
const String Send_Location_Url =
    Base_Url + 'PushNotifications/sendCrimeNotification';
const String Notification_Url =
    Base_Url + "PushNotifications/GetUserNotification?userId=";
const String Update_User_Url = Base_Url + 'User/User';
const String Update_Password_Url = Base_Url + 'User/forgetPassword';
//chats
const String Post_GroupChat_Url = Base_Url + 'Chat/GroupChat';
const String Post_AgentChat_Url = Base_Url + 'Chat/AgentChat';
const String Get_ListGroupChat_Url = Base_Url + 'Chat/ListGroupChat?crimeId=';
const String Get_ListAgentChat_Url = Base_Url + 'Chat/ListAgentChat?senderId=';

const String Get_NearestPerson_Url =
    Base_Url + 'User/getNearestPerson?latitude=13.1442336&longitude=79.9099998';

const String Get_LocationHistory_Url =
    Base_Url + 'User/getUserLocation?userId=';

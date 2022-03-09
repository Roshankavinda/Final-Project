import * as React from 'react';
import { createAppContainer, createSwitchNavigator} from "react-navigation";
import { createStackNavigator } from "react-navigation-stack";
import { createBottomTabNavigator } from 'react-navigation-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons'

import LoadingScreen from "./screens/LoadingScreen";
import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";
import MessageScreen from "./screens/MessageScreen";
import PostScreen from "./screens/PostScreen";
import NotificationScreen from "./screens/NotificationScreen";
import ProfileScreen from "./screens/ProfileScreen";

import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import 'firebase/compat/firestore';

 export const firebaseConfig = {
  apiKey: "AIzaSyCQazdLG0-UrcwwHsMWv8g1xyR2F1UPnSs",
  authDomain: "collegeapp-9a284.firebaseapp.com",
  projectId: "collegeapp-9a284",
  storageBucket: "collegeapp-9a284.appspot.com",
  messagingSenderId: "723049608751",
  appId: "1:723049608751:web:af72b7b64c9f65cbbb78da"
};

export const firebaseApp = firebase.initializeApp(firebaseConfig);
firebase.firestore();
 
const AppTabNavigator = createBottomTabNavigator(
  {
    Home: {
      screen: HomeScreen,
      navigationOptions: {
        tabBarIcon: ({tintColor}) => <Ionicons name="ios-home" size={24} color={tintColor}/>
      }
    },
    Message: {
      screen: MessageScreen,
      navigationOptions: {
        tabBarIcon: ({tintColor}) => <Ionicons name="chatboxes" size={24} color={tintColor}/>
      }
    },
    Post: {
      screen: PostScreen,
      navigationOptions:{
        tabBarIcon: ({ tintColor }) => (
          <Ionicons
            name="ios-add-circle"
            size={48}
            color= "#22c94f"
            style={{
              shadowColor: "#E9446A",
              shadowOffset: {width: 0, height: 0},
              shadowRadius: 10,
              shadowOpacity: 0.3
            }}
          />
        )
      }  
    },
    Notification: {
      screen: NotificationScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => <Ionicons name="ios-notifications" size={24} color= {tintColor}/>
      }
    },
    Profile: {
    screen: ProfileScreen,
    navigationOptions: {
      tabBarIcon: ({ tintColor }) => <Ionicons name="ios-person" size={24} color= {tintColor}/>
     }
    }
  },
  {
    tabBarOptions: {
      activeTintColor: "#161F3D",
      inactiveTintColor: "#B8BBC4",
      showLabel: false
    }
  }
);

const AuthStack = createStackNavigator({
 Login: LoginScreen,
})

export default createAppContainer(
   createSwitchNavigator(
       {
           Loading: LoadingScreen,
           App: AppTabNavigator,
           Auth: AuthStack
       },
       {
           initialRouteName: "Loading"
       }
   )
);


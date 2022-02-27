import { createAppContainer, createSwitchNavigator} from "react-navigation";
import { createStackNavigator } from "react-navigation-stack";
import LoadingScreen from "./screens/LoadingScreen";
import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";

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

const AppStack = createStackNavigator({
  Home: HomeScreen
})

const AuthStack = createStackNavigator({
  Login: LoginScreen
})

export default createAppContainer(
   createSwitchNavigator(
       {
           Loading: LoadingScreen,
           App: AppStack,
           Auth: AuthStack
       },
       {
           initialRouteName: "Loading"
       }
   )
);


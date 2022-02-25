import { createAppContainer, createSwitchNavigator } from "react-navigation";
import { createStackNavigator } from "react-navigation-stack";
import LoadingScreen from "./screens/LoadingScreen";
import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";

import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyDM59jzv5Hx8XKOkvXuyBXyCITbMjB44Oo",
  authDomain: "collegeapp-ca399.firebaseapp.com",
  projectId: "collegeapp-ca399",
  storageBucket: "collegeapp-ca399.appspot.com",
  messagingSenderId: "91117096836",
  appId: "1:91117096836:web:b848bd95b422a0d9c197d1"
};

const app = initializeApp(firebaseConfig);

const AppStack = createStackNavigator({
  Home: HomeScreen
})

const AuthStack = createStackNavigator({
  Login: LoginScreen,
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
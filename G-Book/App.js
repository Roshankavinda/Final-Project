import { StatusBar } from 'expo-status-bar';
import React, { Component } from 'react';
import { Text, View } from 'react-native';

import * as firebase from 'firebase'

const firebaseConfig = {
  apiKey: "AIzaSyAWxtuU8mLxbQO6PPgL2cnUtrs_H8PrkVY",
  authDomain: "gbook-5fac3.firebaseapp.com",
  projectId: "gbook-5fac3",
  storageBucket: "gbook-5fac3.appspot.com",
  messagingSenderId: "283194847117",
  appId: "1:283194847117:web:5615ec1d99cac9c53e17c4",
  measurementId: "G-Y0F4T86Y0Z"
};

if (firebase.apps.length === 0) {
  firebase.initializeApp(firebaseConfig)
}

import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import LandingScreen from './components/auth/Landing'
import LoginScreen from './components/auth/Login';

const Stack = createStackNavigator();

export class App extends Component {
  constructor(props){
    super(props);
    this.state = {
      loaded: false,
    }
  }

  componentDidMount(){
    firebase.auth().onAuthStateChanged((user) => {
      if(!user){
        this.setState({
          loggedIn: false,
          loaded: true,
        })
      }else{
        this.setState({
          loggedIn: true,
          loaded: true,
        })
      }
    })
}
  render() {
    const { loggedIn, loaded } = this.state;
    if(!loaded){
      return(
        <View style={{flex: 1, justifyContent: 'center'}}>
          <Text>Loading</Text>
        </View>
      )
    }
    return (
      <NavigationContainer>
      <Stack.Navigator initialRouteName="Landing">
            <Stack.Screen name="Landing" component={LandingScreen} options={{ headerShow: false}} />
            <Stack.Screen name="Login" component={LoginScreen} />
          </Stack.Navigator>
      </NavigationContainer>
    );
  }
}

export default App;

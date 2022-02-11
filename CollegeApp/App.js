import { StatusBar } from 'expo-status-bar';
import React, { Component } from 'react';

import { View, Text } from 'react-native';

import firebase from 'firebase';


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
          <Text></Text>
        </View>
      )
    }

    if(!loggedIn){
      return (
        <NavigationContainer>
        <Stack.Navigator initialRouteName="Landing">
          <Stack.Screen name="Landing" component={LandingScreen} options={{ headerShow: false}} />
          <Stack.Screen name="Login" component={LoginScreen} />
        </Stack.Navigator>
        </NavigationContainer>
      );
    }

    return(
      <View style={{flex: 1, justifyContent: 'center'}}>
        <Text>User</Text>
      </View>
    )
  }
}

export default App;
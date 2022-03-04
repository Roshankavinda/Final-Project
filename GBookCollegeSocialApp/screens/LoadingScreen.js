import React from 'react';
import {View, Text, StyleSheet, ActivityIndicator} from "react-native";

import 'firebase/compat/auth';
import { getAuth, onAuthStateChanged } from "firebase/auth";

import {firebaseApp} from '../App'
import firebase from 'firebase/compat/app';

export default class LoadingScreen extends React.Component{
    componentDidMount(){
        const auth =getAuth(firebaseApp);onAuthStateChanged(auth, user => {
            this.props.navigation.navigate(user ? "App" : "Auth");
        });
    }
    render(){
        return(
            <View style={style.container}>
                <Text>Loading...</Text>
                <ActivityIndicator size="large"></ActivityIndicator>
            </View>
        );  
     }
}


const style = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center"
    }
});
/*import React from 'react';
import {View, Text, StyleSheet, ActivityIndicator} from "react-native";
import * as firebase from "firebase/app";

export default class LoadingScreen extends React.Component{
    componentDidMount(){
        firebase.auth().onAuthStateChanged(user => {
            this.props.navigation.navigate(user ? "App" : "Auth")
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
});*/
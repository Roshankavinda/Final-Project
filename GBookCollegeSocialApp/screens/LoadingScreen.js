import React from "react";
import {View, Text, StyleSheet, ActivityIndicator} from "react-native";

export default class LoadingScreen extends React.Component{
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
import React from "react";
import {View, Text, StyleSheet} from "react-native";

export default class LoginScreen extends React.Component{
    render(){
        return(
            <View style={style.container}>
                <Text style={style.greeting}>{`Hello again.\nWelcome back.`}</Text>
            </View>
        );
    }
}

const style = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center"
    },
    greeting:{
        marginTop: 32,
        fontSize: 18,
        fontWeight: "400",
        textAlign: "center"
    }
});
import React from "react";
import {View, Text, StyleSheet, TextInput, TouchableOpacity, Image, StatusBar, LayoutAnimation} from "react-native"


export default class LoginScreen extends React.Component{
    static navigationOptions = {
        headerShown: false
    };

    render(){
        LayoutAnimation.easeInEaseOut();
        return(
            <View style={styles.container}>
                <StatusBar barStyle="light-content"></StatusBar>
                <Image 
                source={require("../assets/Logo.png")} 
                style={{marginTop: 30, marginLeft: 30}}
                ></Image>

                <Image
                source={require("../assets/Border.png")}
                style={{ bottom: -45, right: 100}}
                ></Image>
                <Text style={styles.greeting}>{`Welcome to GBOOK.\nSign up to get started.`}</Text>


                <View style={styles.form}>
                    <View style={{marginTop: 50}}>
                        <Text style={styles.inputTitle}>Email Address</Text>
                        <TextInput 
                        style={styles.input} 
                        autoCapitalize="none"
                        //onChangeText={text => setEmail(text)}
                        //value={email}
                        ></TextInput>
                    </View>

                    <View style={{marginTop: 32}}>
                        <Text style={styles.inputTitle}>Password</Text>
                        <TextInput 
                        style={styles.input} 
                        secureTextEntry 
                        autoCapitalize="none"
                        //onChangeText={text => setPassword(text)}
                        //value={password}
                        ></TextInput>
                    </View>
                </View>

                <TouchableOpacity style={styles.button} /*onPress={handleSignUp}*/>
                    <Text style={{color:"black", fontWeight: "bold"}}>Sign Up</Text>
                </TouchableOpacity>

                <TouchableOpacity 
                           style={{alignSelf: "center", marginTop: 32}}  
                           onPress={() => this.props.navigation.navigate("Login")}     
                >
                    <Text style={{color: "#414959", fontSize: 15}}>
                        GBook User?<Text style={{fontWeight: "bold", color: "#024d1b"}}>Login</Text>
                    </Text>
                </TouchableOpacity>
            </View>
            
        );
    }
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    greeting:{
        marginTop: -700,
        fontSize: 25,
        fontWeight: "500",
        textAlign: "center"
    },
    form:{
        marginBottom: 48,
        marginHorizontal: 30
    },
    inputTitle:{
        color: "#8A8F9E",
        fontSize: 10,
        textTransform: "uppercase"
    },
    input:{
        borderBottomColor: "#8A8F9E",
        borderBottomWidth: StyleSheet.hairlineWidth,
        height: 40,
        fontSize: 15,
        color: "#161F3D"
    },
    button:{
        marginHorizontal: 30,
        backgroundColor: "#22c94f",
        borderRadius: 4,
        height: 52,
        alignItems: "center",
        justifyContent: "center"
    }
});
import React from "react";
import {View, Text, StyleSheet, TextInput, TouchableOpacity, Image, StatusBar, LayoutAnimation} from "react-native";
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';

export default class LoginScreen extends React.Component{
    static navigationOptions = {
        header: null
    };

    state ={
        email:"",
        password: "",
        errorMessage: null
    };

    handleLogin = () =>{
        const {email, password} = this.state

        firebase
        .auth()
        .signInWithEmailAndPassword(email, password)
        .catch(error => this.setState({errorMessage:error.message}));
    }
    render(){
        return(
            <View style={styles.container}>
                <StatusBar barStyle="light-content"></StatusBar>
                <Image 
                source={require("../assets/Logo.png")} 
                style={{marginTop: 0, marginLeft: 30}}
                ></Image>

                <Image
                source={require("../assets/Border.png")}
                style={{ bottom: -100, right: 100}}
                ></Image>
                <Text style={styles.greeting}>{`Hello again.\nWelcome back.`}</Text>

                <View style={styles.errorMessage}>
                 {this.state.errorMessage && <Text style={styles.error}>{this.state.errorMessage}</Text>}
            </View>

                <View style={styles.form}>
                    <View>
                        <Text style={styles.inputTitle}>Email Address</Text>
                        <TextInput 
                        style={styles.input} 
                        autoCapitalize="none"
                        onChangeText={email => this.setState({email})}
                        value={this.state.email }
                        ></TextInput>
                    </View>

                    <View style={{marginTop: 32}}>
                        <Text style={styles.inputTitle}>Password</Text>
                        <TextInput 
                        style={styles.input} 
                        secureTextEntry 
                        autoCapitalize="none"
                        onChangeText={password => this.setState({password})}
                        value={this.state.email}
                        ></TextInput>
                    </View>
                </View>

                <TouchableOpacity style={styles.button} onPress={this.handleLogin}>
                    <Text style={{color:"black", fontWeight: "bold"}}>Sign in</Text>
                </TouchableOpacity>

                <TouchableOpacity 
                           style={{alignSelf: "center", marginTop: 32}} 
                           onPress={() => this.props.navigation.navigate("Home")}       
                >
                    <Text style={{color: "#414959", fontSize: 15}}>
                        New to GBook?<Text style={{fontWeight: "bold", color: "#024d1b"}}> Sign Up</Text>
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
    errorMessage:{
        height: 72,
        alignItems: "center",
        justifyContent: "center",
        marginHorizontal: 30
    },
    error:{
        color: "#E9446A",
        fontSize: 13,
        fontWeight: "600",
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
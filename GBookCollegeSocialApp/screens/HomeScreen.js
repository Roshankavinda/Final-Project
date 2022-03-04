import React from "react";
import {View, Text, StyleSheet, TouchableOpacity} from "react-native";
import 'firebase/compat/auth';
import {firebaseApp} from '../App'
export default class HomeScreen extends React.Component{
    state ={
        email: "",
        displayName: ""
    }

    componentDidMount(){
         const {email, displayName} = firebaseApp.auth().currentUser;

         this.setState({email, displayName})
    }

    signOutUser = () => {
        firebaseApp.auth().signOut();
    };

    render(){
        return(
            <View style={style.container}>
                <Text>Hi {this.state.email}!</Text>

                <TouchableOpacity style={{marginTop: 32}} onPress={this.signOutUser}>
                    <Text>Logout</Text>
                </TouchableOpacity>
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
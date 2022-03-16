import React from 'react'
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, Image, TextInput } from 'react-native'
import Ionicons from 'react-native-vector-icons/Ionicons';
import Contants from "expo-constants";
import * as Permission from "expo-permissions"

export default class PostScreen extends React.Component{
    render(){
        return(
            <SafeAreaView style={styles.container}>
                <View style={styles.header}>
                    <TouchableOpacity>
                        <Ionicons name="ios-arrow-back-circle" size={24} color="#6f7872" style={{marginLeft: -20}}></Ionicons>
                    </TouchableOpacity>
                    <TouchableOpacity>
                        <Text style={{fontWeight: "600", fontSize: 20}}>Post</Text>
                    </TouchableOpacity>
                </View>

                <View style={styles.inputContainer}>
                   <Image source={require("../assets/Kayla-Person.jpg")} style={styles.avatar}></Image>
                   <TextInput
                      autoFocus={true}
                      multiline={true}
                      numberOfLines={4}
                      style={{flex: 1}}
                      placeholder="Want to share something?"
                   ></TextInput>
                </View>

                <TouchableOpacity style={styles.photo}>
                    <Ionicons name="ios-camera" size={32} color="#0e120f"></Ionicons>
                </TouchableOpacity>
            </SafeAreaView>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1
    },
    header: {
        flexDirection: "row",
        justifyContent: "space-between",
        paddingHorizontal: 32,
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: "#D8D9DB"
    },
    inputContainer:{
        margin: 32,
        flexDirection: "row"
    },
    avatar:{
        width: 48,
        height: 48,
        borderRadius: 24,
        marginRight: 16
    },
    photo: {
        alignItems: "flex-end",
        marginHorizontal: 32
    }
});
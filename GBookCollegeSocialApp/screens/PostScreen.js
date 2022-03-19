import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, Image, TextInput } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import Contants from "expo-constants";
import * as Permissions from "expo-permissions";
import * as ImagePicker from 'expo-image-picker'

export default class PostScreen extends React.Component{
    
    componentDidMount() {
        this.getPhotoPermission();
    }

    getPhotoPermission = async () => {
        if (Contants.platform.android){
            const { status } = await Permissions.askAsync(Permissions.CAMERA_ROLL);

            if (status != "granted") {
                alert("We need permission to access your camera");
            }
        } 
    };

    pickImage = async () => {
         let result = await ImagePicker.launchImageLibraryAsync({
             mediaTypes: ImagePicker.MediaTypeOptions.Images,
             allowsEditing: true,
             aspect: [4,3]
         });

         if (!result.cancelled){
             this.setState({image: result.uri});
         }
    };

    render(){
        return(
            <SafeAreaView style={styles.container}>
                <View style={styles.header}>
                    <TouchableOpacity onPress={() => this.props.navigation.goBack()}>
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

                <TouchableOpacity style={styles.photo} onPress={this.pickImage}>
                    <Ionicons  name="ios-camera" size={32} color="#9e9a99" style={{marginTop: -20}}></Ionicons>
                </TouchableOpacity>

                <View style={{marginHorizontal: 32, marginTop: 32, height: 150}}>
                    <Image source={require("../assets/2.jpg")} style={{width:"100%", height: "100%"}}></Image>
                </View>
            </SafeAreaView>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1
    },
    header: {
        marginTop: 20,
        flexDirection: "row",
        justifyContent: "space-between",
        paddingHorizontal: 32,
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: "#D8D9DB",
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
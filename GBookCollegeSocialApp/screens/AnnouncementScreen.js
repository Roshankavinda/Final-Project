
import React from 'react'
import { View, Text, StyleSheet } from 'react-native'

export default class AnnouncementScreen extends React.Component{
    render(){
        return(
            <View style={style.container}> 
                <Text>Announcement Screen</Text>
            </View>
        )
    }
}

const style = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: "center",
        justifyContent:"center"
    }
})
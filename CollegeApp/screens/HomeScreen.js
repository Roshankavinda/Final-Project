import React from 'react'
import { View, Text, SafeAreaView, StyleSheet } from 'react-native'
import Header from '../components/home/Header'
import Stories from '../components/home/Stories'
import Post from '../components/home/Post'
import { ScrollView } from 'react-native-web'


const HomeScreen = () => {
    return <SafeAreaView style={styles.container}>
        <Header/>
        <Stories/>
        <ScrollView>
           {POSTS.map((post, index) => (
           <Post post={post} key={index}/>
           ))}
        </ScrollView>
        </SafeAreaView>
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: '#9CB071',
        flex: 1,
    },
})

export default HomeScreen

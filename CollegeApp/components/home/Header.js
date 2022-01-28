import { View, Text, Image, StyleSheet,TouchableOpacity } from 'react-native'



const Header = () => {
    return (
        <View style={styles.container}>
            <TouchableOpacity>
            <Image 
               style={styles.logo} 
               source={require('../../assets/Logo.png')}
            />
            </TouchableOpacity>

            <View style={styles.iconsContainer}>
            <TouchableOpacity>
               <Image
                  source={{
                      uri: 'https://img.icons8.com/ios/2x/plus-2-math.png'
                  }}
                  style={styles.icon}
                />  
            </TouchableOpacity>
            <TouchableOpacity>
               <Image
                  source={{
                      uri: 'https://img.icons8.com/ios-filled/2x/search.png'
                  }}
                  style={styles.icon}
                />  
            </TouchableOpacity>
            <TouchableOpacity>
               <Image
                  source={{
                      uri: 'https://img.icons8.com/ios-filled/2x/chat.png'
                  }}
                  style={styles.icon}
                />  
            </TouchableOpacity>
            </View>
        </View>
    )
}

const styles =StyleSheet.create({
container:{
    justifyContent: 'space-between',
    alignItems: 'center',
    flexDirection: 'row',
    marginHorizontal: 20,
},

iconsContainer:{
    flexDirection: 'row',
    marginTop:20,
},

    logo:{
        marginTop:18,
        marginLeft: -30,
        width: 190,
        height: 50,
       
    },

    icon:{
        width: 100,
        height: 30,
        marginLeft: -15,
        marginRight: -40,
        marginTop:10,
        resizeMode: 'contain',
        
    },
    
})

export default Header

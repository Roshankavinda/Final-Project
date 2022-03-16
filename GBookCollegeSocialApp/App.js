import * as React from 'react';
import { createAppContainer, createSwitchNavigator} from "react-navigation";
import { createStackNavigator } from "react-navigation-stack";
import { createBottomTabNavigator } from 'react-navigation-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons'

import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";
import MessageScreen from "./screens/MessageScreen";
import PostScreen from "./screens/PostScreen";
import NotificationScreen from "./screens/NotificationScreen";
import ProfileScreen from "./screens/ProfileScreen";
import ForumScreen from './screens/ForumScreen';
import AnnouncementScreen from './screens/AnnouncementScreen';
import RegisterScreen from './screens/RegisterScreen';

const AppContainer = createStackNavigator(
  {
     default: createBottomTabNavigator(
      {
        Home: {
          screen: HomeScreen,
          navigationOptions: {
            tabBarIcon: ({tintColor}) => <Ionicons name="ios-home" size={24} color={tintColor}/>
          }
        },
        Forum: {
          screen: ForumScreen,
          navigationOptions: {
            tabBarIcon: ({tintColor}) => <Ionicons name="ios-logo-stackoverflow" size={24} color={tintColor}/>
          }
        },
        Message: {
          screen: MessageScreen,
          navigationOptions: {
            tabBarIcon: ({tintColor}) => <Ionicons name="ios-chatbubbles" size={24} color={tintColor}/>
          }
        },
        Post: {
          screen: PostScreen,
          navigationOptions:{
            tabBarIcon: ({ tintColor }) => (
              <Ionicons
                name="ios-add-circle"
                size={48}
                color= "#22c94f"
                style={{
                  shadowColor: "#E9446A",
                  shadowOffset: {width: 0, height: 0},
                  shadowRadius: 10,
                  shadowOpacity: 0.3
                }}
              />
            )
          }  
        },
        Notification: {
          screen: NotificationScreen,
          navigationOptions: {
            tabBarIcon: ({ tintColor }) => <Ionicons name="ios-notifications" size={24} color= {tintColor}/>
          }
        },
        Announcement: {
          screen: AnnouncementScreen,
          navigationOptions: {
            tabBarIcon: ({ tintColor }) => <Ionicons name="ios-megaphone-sharp" size={24} color= {tintColor}/>
          }
        },
        Profile: {
        screen: ProfileScreen,
        navigationOptions: {
          tabBarIcon: ({ tintColor }) => <Ionicons name="ios-person" size={24} color= {tintColor}/>
         }
        }
      },
      {
          defaultNavigationOptions:{
             tabBarOnPress: ({navigation, defaultHandler}) => {
               if (navigation.state.key === "Post") {
                 navigation.navigate("postModel")
               } else {
                 defaultHandler()
               }
             }
          },
          tabBarOptions: {
             activeTintColor: "#161F3D",
             inactiveTintColor: "#B8BBC4",
             showLabel: false
        }
      }
     ),
     postModel: {
       screen: PostScreen
     }
  },
  {
    mode: "modal",
    headerMode: "none",
    initialRouteParams: "postModal"
  }
)
 

const AuthStack = createStackNavigator({
  Login: LoginScreen,
  Register: RegisterScreen

})

export default createAppContainer(
   createSwitchNavigator(
       {
        
        Auth: AuthStack,   
        App: AppContainer,
           
       }
   )
);


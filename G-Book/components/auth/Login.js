import React, { Component } from 'react';
import { View, Button, TextInput } from 'react-native'

export class Login extends Component {
    constructor(props){
        super(props);

        this.state = {
            email: '',
            password: ''
        }
        this.onSignUp = this.onSignUp.bind(this)
    }

    onSignUp(){
        
   }

    render() {
        return (
              <View>
                 <TextInput
                       placeholder="email"
                       onChangeText={(email) => this.setState({email})}
                 />
                 <TextInput
                       placeholder="password"
                       secureTextEntry={true}
                       onChangeText={(password) => this.setState({password})}
                 />
                 
                 <Button
                     onPress={() => this.onSignIn()}
                     title='Sign In'
                 />
              </View>
        );
      }
    }
    
    export default Login;
    
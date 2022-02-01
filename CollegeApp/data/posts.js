import { USERS } from "./users";

export const POSTS = [
    {
        imageurl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHBlb3BsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
        user: USERS[0].user,
        likes: 7810,
        caption: 'Just Me.',
        profile_picture: USERS[0].image,
        Comments:[
            {
                user: 'theqazaman',
                Comment: 'Wow!'
            },
            {
                user: 'roshan',
                Comment: 'Amazing!'
            },
        ],
    },
    {
        imageurl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHBlb3BsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
        user: USERS[1].user,
        likes: 7810,
        caption: 'Just Me.',
        profile_picture: USERS[1].image,
        Comments:[
            {
                user: 'theqazaman',
                Comment: 'Wow!'
            },
            {
                user: 'roshan',
                Comment: 'Amazing!'
            },
        ],
    }
]

const PORT = process.env.PORT || 3000;

import  {WebSocketServer} from 'ws';
import express from 'express';

const app = express();
const router = express.Router();
const wss = new WebSocketServer({ port: process.env.WSPORT || 8080 });


app.use(express.json());
app.use('/', router);

let gameState = []
let currentId = 0;

wss.on('connection', (ws) => {
    console.log("Godot client connected!");
    // server/client handshake
    ws.send("connected");


    ws.on('message', (message) => {
        // If Godot sends a message to increment
        const data = JSON.parse(message);
        
        //console.log(data);

        if (data.action === "get_id") {
            console.log(currentId);
            ws.send(JSON.stringify({newId : currentId.toString()}))

            const push = {
                "position" : [320,360],
                "id" : currentId
            }

            gameState.push(push)

            currentId++;
        } else if (data.action === "update_x_position") {
            gameState[data.id].position[0] = data.x;
            console.log("Player id: ", data.id, " | ", gameState[data.id].position)
            sendPosition(data);
            
        } else if (data.action === "update_y_position") {
            gameState[data.id].position[1] = data.y;
            console.log("Player id: ", data.id, " | ", gameState[data.id].position)
            sendPosition(data);
        } else if (data.action === "bullet") {
            console.log("player " + data.id + " sent a bullet to " + data.cords);
            
            const send = {"action" : "bullet", "id":data.id, "cords" : data.cords};

            wss.clients.forEach((client) => {
                if (client.readyState ===1) {
                    client.send(JSON.stringify(send));
                }
            })
            
        }
    });

    ws.on('close', (code, reason) => {
        console.log(`Player ${reason} disconnected`);
        gameState.pop(parseInt(reason))
        currentId --;

    })

});

const sendPosition = (data) => {

    const playerId = data.id;
    const x = gameState[playerId].position[0];
    const y = gameState[playerId].position[1];

    const send = {"action" : "newPosition", "id":playerId, "position" : [x, y]};
    
    wss.clients.forEach((client) => {
                if (client.readyState ===1) {
                    client.send(JSON.stringify(send));
                }
            })
}


app.listen(PORT, () => {
    console.log(`API is running on port ${PORT}`);
})
console.log("Server is running on ws://localhost:8080");
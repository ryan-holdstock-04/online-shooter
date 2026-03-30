import * as dotenv from 'dotenv';
dotenv.config();

const PORT = process.env.WSPORT || 8080;
console.log(process.env.WSPORT);

import  {WebSocketServer} from 'ws';

const wss = new WebSocketServer({ port: PORT });




let gameState = []
let currentId = 0;

wss.on('connection', (ws) => {
    // server/client handshake
    ws.send("connected");

    ws.on('message', (message) => {
        // If Godot sends a message to increment
        const data = JSON.parse(message);
        
        //console.log(data);

        if (data.action === "get_id") {
            console.log("Player " + currentId + " connected");
            ws.send(JSON.stringify({newId : currentId.toString()}))

            const push = {
                "position" : [320,360],
                "id" : currentId
            }

            gameState.push(push)

            currentId++;
        } else if (data.action === "update_x_position") {
            gameState[data.id].position[0] = data.x;
            sendPosition(data);
        } else if (data.action === "update_y_position") {
            gameState[data.id].position[1] = data.y;
            sendPosition(data);
        } else if (data.action === "bullet") {            
            sendBullet(data);
        } else if (data.action === "update_health") {
            console.log(data);
            sendHealth(data);
        }
    });

    ws.on('close', (code, reason) => {
        console.log(`Player ${reason} disconnected`);
        gameState.pop(parseInt(reason))
        currentId --;

    })

});

const sendHealth = data => {
    const send = {"action" : "update_health", "newhealth" : data.newhealth, "id":data.id}
    wss.clients.forEach((client) => {
            if (client.readyState ===1) {
                client.send(JSON.stringify(send));
            }
        });
}

const sendBullet = (data) => {
    const send = {"action" : "bullet", "id":data.id, "cords":data.cords};
    wss.clients.forEach((client) => {
        if (client.readyState ===1) {
            client.send(JSON.stringify(send));
        }
    });
}

const sendPosition = (data) => {

    const playerId = data.id;
    const x = gameState[playerId].position[0];
    const y = gameState[playerId].position[1];

    const send = {"action" : "newPosition", "id":playerId, "position" : [x, y]};
    
    wss.clients.forEach((client) => {
                if (client.readyState ===1) {
                    client.send(JSON.stringify(send));
                }
            });
}
console.log(`Server is running on port ${PORT}`);
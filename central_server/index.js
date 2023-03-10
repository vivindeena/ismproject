require("dotenv").config();
const express = require("express");
const nodemail = require('nodemailer');
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const fs = require("fs");
const cors = require('cors');

function read(){
    return JSON.parse(fs.readFileSync("data.json", "utf8"));
}

function write(data) {
    fs.writeFileSync("./data.json", JSON.stringify(data), (err) => {
        if (err) console.log("Error writing file:", err);
    });
}

function isConfigured(){
    return read().configured;
}

// function isBlacklisted(username) {
//     const data = JSON.parse(fs.readFileSync("blacklist.json", "utf8")).list;
//     if(data.includes(username)){
//         return true;
//     } else {
//         return false;
//     }
// }

// function blacklist(username) {
//     if(!isBlacklisted()){
//         const data = JSON.parse(fs.readFileSync("blaclist.json","utf-8")).list.append(username);
//         fs.writeFileSync("./blacklist.json", JSON.stringify(data), (err) => {
//           if (err) console.log("Error writing file:", err);
//         });
//     }
// }

// function removeBlacklist(username) {   
// }

const app = express()
app.use(express.json());
app.use(cors())
app.use(express.urlencoded({ extended: true }));


app.listen(process.env.PORT, () => {
    console.log("Server Started on port", process.env.PORT);
});

app.post("/delete",(req,res)=>{
    //auth with server password, then invalidate client deamon token
});

app.post("/config", (req,res)=>{ //done
    if (!req.body.email || !req.body.server_password || !req.body.client_password) {
        return res.status(400).json({
            errorMessage: "Missing Required Params",
        });
    }
    if(isConfigured()){
        return res.status(400).json({
            errorMessage: "Server Already configured",
        });
    } else{
        data = read();
        
        bcrypt.hash(req.body.server_password, 10, function (err, hash) {
            if(err){
                console.log("Error in bcrypt",err);

            }else{
                data.server_password = hash;
                bcrypt.hash(req.body.client_password, 10, function (err, hash) {
                    if (err) {
                        console.log("Error in bcrypt", err);
                    } else {
                        data.client_password = hash;
                        write(data);
                    }
                });
                data.configured = true;
                data.user_email = req.body.email;
                write(data);
                return res.status(200).json({
                  errorMessage: "Server configured sucessesfully",
                });
            }
        });
        
    }
});

app.post("/add",  (req,res)=>{
    if (!req.body.client_username || !req.body.password) {
      return res.status(400).json({
        errorMessage: "Missing Required Params",
      });
    }
    if (!isConfigured()) {
      return res.status(400).json({
        errorMessage: "Server is not configured",
      });
    }
    const user_password = read().client_password
    bcrypt.compare(req.body.password, user_password)
        .then((result) => {

          if (!result) {
            return res.status(400).send('Invalid Password or Email')
          }
          else{
            data = read();
            if(!data.clients.includes(req.body.client_username))
            {
                data.clients.push(req.body.client_username);
                write(data)
            }
            jwt.sign(
              {client_username: req.body.client_username},process.env.SECRET_KEY,{ expiresIn: 3600 },(err, token) => {
                if (err) {
                    console.log(err)
                }
                return res.status(200).json({
                  token,
                });
              }
            );
          }
    });
});

app.post("/send-mail", verifyToken, (req, res) => {
    if ( !req.body.subject || !req.body.body) {
        return res.status(400).json({
            errorMessage: "Missing Required Params",
        });
    }
    if (!isConfigured()) {
      return res.status(400).json({
        errorMessage: "Server is not configured",
      });
    }
    

    message = {
        to: read().user_email, 
        from: process.env.GMAIL_ID,
        subject: req.body.subject,
        text: req.body.body,
    };
    let mailTransporter = nodemail.createTransport({
        service: "gmail",
        auth: {
            user: process.env.GMAIL_ID,
            pass: process.env.GMAIL_APP_PASSWD,
        },
    });
    mailTransporter.sendMail(message, (err) => {
        if (err) {
            return res.status(200).json({
                mailStatus: "Unsuccessful",
                error: err,
            });
        } else {
            return res.status(200).json({
                mailStatus: "Successfully sent",
            });
        }
    });
});

function verifyToken(req,res,next) {
    const bearerHeader = req.headers["authorization"];
    if (typeof bearerHeader !== "undefined") {
        const bearerToken = bearerHeader.split(" ")[1];
        jwt.verify(bearerToken,process.env.SECRET_KEY,(err,authData) =>{
            if(err){
                res.sendStatus(403).json({
                  errorMessage: "Authorization failed",
                });
            } else {
                console.log(authData)
                next();
            }
        });

    } else {
        res.sendStatus(403).json({
            errorMessage: "Authorization token missing"
        });
    }
}





// need storing
// 1. user email id
// 2. 2 password
//  a. Use to login to the server
//  b. use to auth clients deaomn to the central mail service
// 3. list of machines (check how to invalidate issued tokens)
// 4. is server configured
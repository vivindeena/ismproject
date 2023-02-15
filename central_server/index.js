require("dotenv").config();
const express = require("express");
const nodemail = require('nodemailer');
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const fs = require("fs");

function read(){
    fs.readFile("data.json", "utf8", (err, jsonString) => {
        if (err) {
            console.log("File read failed:", err);
            return;
        }
        console.log("File data:", jsonString);
        return JSON.parse(jsonString)
    });
}

function write(data) {
    fs.writeFile("./customer.json", JSON.stringify(data), (err) => {
        if (err) console.log("Error writing file:", err);
    });
}

function isConfigured(){
    data = read();
    if (!data[configured]) {
      return res.status(400).json({
        errorMessage: "Server is not configured",
      });
    }
}

const app = express()

app.listen(PORT, () => {
    console.log("Server Started on port", PORT);
});

app.post("/delete",(req,res)=>{
    //auth with server password, then invalidate client deamon token
});

app.post("/config", (req,res)=>{
    if (! req.body.email || !req.body.server_password || !req.body.client_password) {
        return res.status(400).json({
            errorMessage: "Missing Required Params",
        });
    }
    if(isConfigured()){
        return res.status(200).json({
            errorMessage: "Server Already configured",
        });
    } else{
        data = read();
        data[configured] = true;
        data[user_email] = req.body.email;
        bcrypt.hash(server_password, 10, function (err, hash) {
            if(err){
                console.log("Error in bcrypt",err);
            }else{
                data[server_password] = hash;
            }
        });
        bcrypt.hash(client_password, 10, function (err, hash) {
            if (err) {
              console.log("Error in bcrypt", err);
            } else {
              data[client_password] = hash;
            }
        });
        write(data);
    }
});

app.post("/add", (req,res)=>{
    if (!req.body.email || !req.body.password) {
      return res.status(400).json({
        errorMessage: "Missing Required Params",
      });
    }
    if (!isConfigured()) {
      return res.status(400).json({
        errorMessage: "Server is not configured",
      });
    }

    //authenticate using user identity username and password using bcrypt
    //return a token
});

app.post("/sendMail", (req, res) => {
    if (!req.body.jwt || !req.body.subject || !req.body.body) {
        return res.status(400).json({
            errorMessage: "Missing Required Params",
        });
    }
    if (!isConfigured()) {
      return res.status(400).json({
        errorMessage: "Server is not configured",
      });
    }
    //sender auth verify using token

    message = {
        to: read()[user_email], 
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





// need storing
// 1. user email id
// 2. 2 password
//  a. Use to login to the server
//  b. use to auth clients deaomn to the central mail service
// 3. list of machines (check how to invalidate issued tokens)
// 4. is server configured?req
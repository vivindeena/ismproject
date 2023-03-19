require("dotenv").config({ path: "../.env" });
const express = require("express");
const nodemail = require('nodemailer');
const bcrypt = require("bcryptjs");
const multer = require("multer");
const jwt = require("jsonwebtoken");
const fs = require("fs");
const cors = require('cors');


const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null,"tmp")
    },
    filename: (req, file, cb) => {
        const d = new Date(Date.now()).toISOString();
        cb(null, `${d.slice(0, 10)} ${d.slice(11, 19)} ${file.originalname}`);
    }
});
const upload = multer({storage: storage });

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

const app = express()
app.use(express.json());
app.use(cors())
app.use(express.urlencoded({ extended: true }));

function verifyToken(req, res, next) {
  const bearerHeader = req.headers["authorization"];
  if (typeof bearerHeader !== "undefined") {
    const bearerToken = bearerHeader.split(" ")[1];
    jwt.verify(bearerToken, process.env.SECRET_KEY, (err, authData) => {
      if (err) {
        res.sendStatus(403).json({
          errorMessage: "Authorization failed",
        });
      } else {
        next();
      }
    });
  } else {
    res.sendStatus(403).json({
      errorMessage: "Authorization token missing",
    });
  }
}

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
                  message: "Server configured sucessesfully",
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
              {client_username: req.body.client_username},process.env.SECRET_KEY,(err, token) => {
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

app.post("/send-mail", verifyToken, upload.single("upload"), (req, res) => {
    if ( !req.body.subject || !req.body.body || !req.file) {
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
      attachments: [
        {
          filename: req.file.originalname,
          path: req.file.path,
        }
      ],
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
            try{
                fs.unlinkSync(req.file.path);
            }catch(err){
                console.log(error);
            }
            return res.status(200).json({
                mailStatus: "Successfully sent",
            });
        }
    });
});

app.listen(process.env.PORT, () => {
  console.log("Server Started on port", process.env.PORT);
});

console.log('Server Start!');

const {Pool} = require('pg');
const http = require('http');
const fs = require('fs');
const dockerNames = require('docker-names');
const express = require('express');
const bodyParser = require('body-parser');

// .envから環境変数を読み込み
require('dotenv').config();

// Cloud SQLの接続情報
const dbConfig = {
    user    : process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host    : process.env.DB_HOST,
    database: process.env.DB_NAME,
    port    : process.env.DB_PORT
};

// テーブル設定
const MAX_ID  = 1 << 30;
const MAX_AGE = 100;
const TABLE_NAME = 'SampleTable'
const createTableQuery = `
CREATE TABLE IF NOT EXISTS
${TABLE_NAME} (
    id   INT         NOT NULL,
    name VARCHAR(50) NOT NULL,
    age  INT         NOT NULL,
    PRIMARY KEY (id)
    );
`;

function getRandomInt(maxValue) {
    return Math.floor(Math.random() * maxValue);
}


// PostgreSQLプールを作成
const pool = new Pool(dbConfig);

// httpサーバーを作成
const PORT = 3000;
const server = http.createServer(async (req, res) => {
    fs.readFile('./index.html', 'utf-8', async (error, data) => {
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.write(data);

        // SQLへ接続
        try {
            const client = await pool.connect();
            res.write('<h2>Connection is succeed.</h2>');
        } catch(error) {
            res.write('<h2>Connection is failed.</h2>');
        }

        // テーブル作成
        try {
            await pool.query('BEGIN');
            await pool.query(createTableQuery);
            await pool.query('COMMIT');
            res.write('<h2>Creating the table is succeed.</h2>');
        } catch(error) {
            res.write('<h2>Creating the table is failed.</h2>');
        }

        // レコードの追加
        try {
            await pool.query('BEGIN');
            await pool.query(`INSERT INTO ${TABLE_NAME} (id, name, age) VALUES (${getRandomInt(MAX_ID)}, '${dockerNames.getRandomName()}', ${getRandomInt(MAX_AGE)});`);
            await pool.query('COMMIT');
            res.write('<h2>Inserting a record is succeed.</h2>');
        } catch(error) {
            res.write('<h2>Inserting a record is failed.</h2>');
        }
        res.end();
    });
});

server.listen(PORT);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }))
app.listen(PORT)
app.get('/api/get', function (req, res) {
    res.send({'message': 'Receive a Get request'})
    console.log('Receive a Get request')
})
app.post('/api/post', function (req, res) {
    res.send({'message': 'Receive a POST request as ' + req.body.text})
    console.log('Receive a POST request')
    console.log(req.body)
})

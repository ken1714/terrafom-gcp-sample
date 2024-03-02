import http from 'http';
import fs from 'fs';
import 'dotenv/config';
import {GoogleAuth} from 'google-auth-library';
import {Storage} from '@google-cloud/storage';

const auth = new GoogleAuth();
const storage = new Storage();


console.log('Server Start!');

const generateV4DownloadSignedUrl = async (bucketName, fileName) => {
    const options = {
        version: 'v4',
        action: 'read',
        expires: Date.now() + 15 * 60 * 1000, // 15 minutes
    };

    const [url] = await storage
        .bucket(bucketName)
        .file(fileName)
        .getSignedUrl(options);

    return url;
}

const generateV4UploadSignedUrl = async (bucketName, fileName) => {
    const options = {
        version: 'v4',
        action: 'write',
        expires: Date.now() + 15 * 60 * 1000, // 15 minutes
        contentType: 'application/octet-stream',
    };

    const [url] = await storage
        .bucket(bucketName)
        .file(fileName)
        .getSignedUrl(options);

    return url;
}

const sendRequest2Backend = async (apiPath) => {
    const requestUrl = process.env.BACKEND_URL || 'http://localhost';

    const client = await auth.getIdTokenClient(process.env.TARGET_AUDIENCE);
    const response = await client.request({
        url: `${requestUrl}${apiPath}`,
        method: 'GET',
    });
    return response.data;
};

const responseData = await sendRequest2Backend('/api/get');

// httpサーバーを作成
const PORT = process.env.PORT || 3000;
const server = http.createServer(async (req, res) => {
    const bucketName = process.env.STORAGE_NAME;
    const downloadUrl = await generateV4DownloadSignedUrl(bucketName, 'data/download_me.txt');
    const uploadUrl   = await generateV4UploadSignedUrl(bucketName, 'data/upload_me.txt');
    fs.readFile('./index.html', 'utf-8', async (error, data) => {
        await res.writeHead(200, {'Content-Type': 'text/html'});
        await res.write(responseData.message);
        await res.write(`<a href=${downloadUrl}>Download URL</a><br>`);
        await res.write(`<a href=${uploadUrl}>Upload URL</a>`);
        await res.end();
    });
});

server.listen(PORT);

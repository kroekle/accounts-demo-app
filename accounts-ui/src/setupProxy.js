const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app) {
  app.use('/usopa',
    // createProxyMiddleware({
    //   target: 'http://localhost:8080',
    //   changeOrigin: true,
    // })
    createProxyMiddleware({
//      target: 'http://localhost:8083',
      // pathRewrite: { '^/usopa': '' },
      target: 'http://accounts.norsebank.com',
      changeOrigin: true,
      // onProxyReq(proxyReq, req, res) {
        // console.log('**Proxied request:**');
        // console.log('  - Method:', req.method);
        // console.log('  - Proxied URL:', `${proxyReq.protocol}//${proxyReq.host}:${proxyReq.port}${proxyReq.path}`);
        // console.log('  - URL:', req.url);
        // console.log('  status: ', res.statusCode)
        // console.log('  - Headers:', req.headers);
      // },
    })
  );
  app.use('/gopa',
    createProxyMiddleware({
//      target: 'http://localhost:8082',
//      pathRewrite: {'^/gopa': ''},
      target: 'http://accounts.norsebank.com',
      changeOrigin: true,
    })
  );
  app.use('/v1/',
    createProxyMiddleware({
//      target: 'http://localhost:8081',
      target: 'http://accounts.norsebank.com',
      changeOrigin: true,
      // onProxyReq(proxyReq, req, res) {
      //   console.log('**Proxied request:**');
      //   console.log('  - Method:', req.method);
      //   console.log('  - xProxied URL:', proxyReq.path);
      //   console.log('  - URL:', req.url);
      //   console.log('  - Headers:', req.headers);
      // },
    })
  );
  app.use('/attributes',
    createProxyMiddleware({
//      target: 'http://localhost:80',
      target: 'http://accounts.norsebank.com',
      changeOrigin: true,
    })
  );

};
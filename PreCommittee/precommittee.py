import os
import urllib
import json

from google.appengine.api import users

import jinja2
import webapp2

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

PAGES_STUB = [{
    'pageId': '1',
    'pageNumber': None,
    'image': '/files/Page_04.jpg',
    'transfers': [{
        'articleId':'012003',
        'amount':'30'
    }]
},{
    'pageId': '2',
    'pageNumber': None,
    'image': '/files/Page_09.jpg',
    'transfers': None
},{
    'pageId': '3',
    'pageNumber': None,
    'image': '/files/Page_26.jpg',
    'transfers': None
}]


class MainPage(webapp2.RequestHandler):

   def get(self):

        template_values = {};

        template = JINJA_ENVIRONMENT.get_template('home.html')
        self.response.write(template.render(template_values))


class UploadFile(webapp2.RequestHandler):
    
    def post(self):

        myfile = self.request.get("file");

        # TODO: save file to storage

        self.response.headers['Content-Type'] = 'application/json'   
        obj = {
            'success': 'true', 
            #'content': myfile
            'url': '/files/test1.pdf' # TODO: replace with saved file URL
        } 
        self.response.out.write(json.dumps(obj))


class Request(webapp2.RequestHandler):
    
    def get(self):

        requestId = self.request.get("id")

        request = {
            'id': requestId,
            'pages': PAGES_STUB,
            'committeeDate': 1388527200000,
            'requestDate': 1388354400000
        } # TODO: get this object from DB

        if requestId is None:
           template_values = {}
            # TODO: create a page with a list of all requests
        else:
            template_values = {                
                'request': request
            }
            template_name = 'requestEdit.html'

        template = JINJA_ENVIRONMENT.get_template(template_name)
        self.response.write(template.render(template_values))

    def post(self):

        reqDate = self.request.get("requestDate")
        comDate = self.request.get("committeeDate")
        fileUrl = self.request.get("requestFileUrl")

        # TODO: break pdf to images and save request and its pages to DB
        
        query_params = {'id': '123'}  # TODO:  replace with the created request's ID
        self.redirect('/request?' + urllib.urlencode(query_params))


class Page(webapp2.RequestHandler):

    def post(self):

        arr = self.request.POST.dict_of_lists()

        # TODO: save post data to DB

        self.response.headers['Content-Type'] = 'application/json'   
        resp = {
            'success': 'true'
            # 'test': arr
        } 
        self.response.out.write(json.dumps(resp))



application = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/uploadFile', UploadFile),
    ('/request', Request),
    ('/page', Page)
], debug=True)
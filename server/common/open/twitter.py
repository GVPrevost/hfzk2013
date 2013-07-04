# -*- coding: cp936 -*-
CONSUMER_KEY = '9lY1CjPgEiQTMNXdYnEiw'
CONSUMER_SECRET = 'hIvCLhG6u37RUfjYI7wa6bHDbjjgGZx6h5S37LTwE'
REQUEST_TOKEN_URL = 'https://api.twitter.com/oauth/request_token'
ACCESS_TOKEN_URL = 'https://api.twitter.com/oauth/access_token'
AUTHORIZE_URL = 'https://api.twitter.com/oauth/authorize'
CALLBACK_URL = 'http://localhost:11080/intf/twitter/callback'
import logging
from urllib import urlencode,quote
import hmac
from hashlib import sha1
from random import getrandbits
from time import time
from urllib2 import urlopen
from json import load
from google.appengine.api import urlfetch
import StringIO

qt = lambda (s):quote(s,'~')

def get_oauth_params(params, base_url, token_secret='',callback_url=CALLBACK_URL,
                     method='POST'):
    default_params = { 
    'oauth_consumer_key': CONSUMER_KEY, 
    'oauth_signature_method': 'HMAC-SHA1',    
    'oauth_timestamp': str(int(time())), 
    'oauth_nonce': hex(getrandbits(64))[2:], 
    'oauth_version': '1.0' 
    }  

    params.update(default_params) 

    if callback_url: # û��callback_urlʱ�Ͳ��ӣ���ʹ��Ĭ�ϻص���ַ 
        params['oauth_callback'] = qt(callback_url) 

    keys = sorted(list(params.keys())) 
    encoded = qt('&'.join(['%s=%s' % (key, params[key]) for key in keys])) 
# ���ӳ�'key1=value1&key2=value2'��ת������ʽ����key���������� 

    base_string = '%s&%s&%s' % (method, qt(base_url), encoded) # ƴ��base string 
    key = CONSUMER_SECRET + '&' + token_secret # ע��token_secret����Ϊ''����Ҳ��Ҫ����'&'����Ҫ�� 

    params['oauth_signature'] = qt(hmac.new(key, base_string, sha1).digest().encode('base64')[:-1]) # ����ȥͦ���ӵ�ǩ�������������ճ��� 

    return params

def qs2dict(s): # ��������ǰ�'key1=value1&key2=value2'ת�����ֵ���� 
    dic = {} 
    for param in s.split('&'): 
        (key, value) = param.split('=') 
        dic[key] = value 
    return dic

def dict2qs(dic): # ��������ǰ��ֵ����ת����'key1="value1", key2="value2"'����ʽ 
    return ', '.join(['%s="%s"' % (key, value) for key, value in dic.iteritems()])

BASE_URL = 'https://api.twitter.com/1.1/%s.json'

class API(object):
    
    def __init__(self, access_token,secret):
        self.__access_token = access_token
        self.__secret = secret
        
    def __request(self, _url, _data):
        
        def get(url):
            return urlopen(url)
        
        def post(url, data):
            return urlopen(url, body=data)
        
        def test_method(s):
            return False
        
        return get(url)
    
    def __getattr__(self, attr):
        
        def wrap(**kw):
            _url = BASE_URL % attr.replace('__', '/')
            data = get_oauth_params(kw, _url, token_secret = self.__oauth_secret)
            data['oauth_token'] = self.__access_token
            del data['oauth_callback']
            res = urlfetch.fetch(_url, headers={'Authorization':'OAuth '+dict2qs(data)}, method='GET').content
            return res#load(StringIO.StringIO(res.encode('utf8')))
        
        return wrap
            
class Twitter(object):
    
    def __init__(self, access_token, secret):
        self.__access_token = access_token
        self.api = API(self.__access_token, secret)

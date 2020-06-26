# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 15:23:06 2019

@author: whan
"""


class QLogger(object):
    __instance = None
    log_records = ""
    new_record = None
    
    @staticmethod
    def getInstance():
        if QLogger.__instance == None:
            QLogger()
        return QLogger.__instance
    def __init__(self):
        if QLogger.__instance != None:
            raise Exception("This class is a Singleton")
        else:
            QLogger.__instance = self

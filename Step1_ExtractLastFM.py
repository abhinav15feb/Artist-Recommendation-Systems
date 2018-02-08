import requests
import json
import datetime
import csv
import sys

def getUser(n=1000):
    user = ["joi"]
    done=[]
    for userid in user:
    #tempfriends=[]
    #tempfriends.append(userid)
        if(userid not in done):
            userresponse = requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user="+str(userid)+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            done.append(userid)
            data = userresponse.json()
            s2 =json.dumps(data['user'])
            d3 = json.loads(s2)
        friendresponse = requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getfriends&user="+str(userid)+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
        frienddata = friendresponse.json()
        s2 =json.dumps(frienddata['friends']['user'])
        d3 = json.loads(s2)
        for i in range(0,len(d3)):
            if(d3[i]['name'] not in user):
                user.append(d3[i]['name'])
        
        if(len(user)>n):
            break
    print (len(user))
    with open('userdetails.csv', 'w', newline='\n') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        spamwriter.writerow (['name','country','age','gender','subscriber','playcount','playlists','bootstrap','registered-unixtime','type'])
        for userid in user:
            userresponse = requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user="+str(userid)+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            done.append(userid)
            data = userresponse.json()
            s2 =json.dumps(data['user'])
            d3 = json.loads(s2)
            try:
                spamwriter.writerow ([str(d3['name']),str(d3['country']),str(d3['age']),str(d3['gender']),str(d3['subscriber']),str(d3['playcount']),str(d3['playlists']),str(d3['bootstrap']),str(d3['registered']['unixtime']),str(d3['type'])])
            except KeyError:
                print("I got a Key Error")
            #datetime.datetime.fromtimestamp(                                    int("1037793040")
            #).strftime('%Y-%m-%d %H:%M:%S')

    f = open('UserID.txt', 'w')
    for d in user:
        f.write(str(d))
        f.write("\n")
    f.close()


def getFriends(UserFile="UserID.txt", OutputFile="User_Friend_Ind.csv"):
    with open('User_Friend.csv', 'w', newline='\n') as csvfile:
        datawriter = csv.writer(csvfile, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        datawriter.writerow (['User','Friends'])
        file = open("UserID.txt", "r")
        users=file.readlines()
        for userid in users:
            tempfriends = []
            userid=userid.replace("\n","")
            tempfriends.append(userid)
            friendresponse = requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getfriends&user="+str(userid)+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            frienddata = friendresponse.json()
            s2 =json.dumps(frienddata['friends']['user'])
            d3 = json.loads(s2)
            for i in range(0,len(d3)):
                datawriter.writerow([userid,d3[i]['name']])
    print ("Friends done")
def getRecentTracks(UserFile="UserID.txt", OutputFile="User_Recent_Track.csv"):
    with open(OutputFile, 'w', newline='\n') as csvfile:
        datawriter = csv.writer(csvfile, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        datawriter.writerow (['User','Artist', 'Song', 'Album', 'Date'])
        file = open(UserFile,"r")
        users=file.readlines()
        for userid in users:
            temprow=[]
            userid=userid.replace("\n","")
            temprow.append(userid)
            #print ("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user="+userid+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            rTrackResponse= requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user="+userid+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            rTrackdata = rTrackResponse.json()
            s2 =json.dumps(rTrackdata['recenttracks']['track'])
            d3 = json.loads(s2)
            for i in range(0,len(d3)):
                try:
                    datawriter.writerow([userid, d3[i]['artist']['#text'],d3[i]['name'],d3[i]['album']['#text'], d3[i]['date']['#text']])
                except KeyError:
                    print ('I got a KeyError ')
            print(userid+"done\n")

def getLovedTracks(UserFile="UserID.txt", OutputFile="User_Loved_track.csv"):
    with open(OutputFile, 'w', newline='\n') as csvfile:
        datawriter = csv.writer(csvfile, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        datawriter.writerow (['User','Song Name','Date','Artist'])
        file = open(UserFile,"r")
        users=file.readlines()
        for userid in users:
            temprow=[]
            userid=userid.replace("\n","")
            temprow.append(userid)
            lTrackResponse= requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user="+userid+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
            lTrackdata = lTrackResponse.json()
            s2 =json.dumps(lTrackdata['lovedtracks']['track'])
            d3 = json.loads(s2)
            for i in range(0,len(d3)):
                try:
                    datawriter.writerow([userid, d3[i]['name'], d3[i]['date']['#text'], d3[i]['artist']['name']])
                except KeyError:
                    print ('I got a KeyError ')
            print(userid+"done\n")

def getArtistDetails(UserFile="Artist-EdgeWeighted.csv", OutputFile="ArtistDetails.csv"):
    with open(OutputFile, 'w', newline='\n') as csvfile:
        datawriter = csv.writer(csvfile, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        datawriter.writerow (['User','Song Name','Date','Artist'])
        with open(UserFile, 'r', newline='\n') as readerfile:
            artist_list=[]
            reader = csv.DictReader(readerfile)
            for row in reader:
                temprow=[]
                artist_name=row['artist1']
                if artist_name not in artist_list:
                    artist_list.append(artist_name)
                    temprow.append(artist_name)
                    lTrackResponse= requests.get("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist="+str(artist_name)+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
                    print ("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist="+artist_name+"&api_key=8e7b6a8671acecb1308a22b74b40734b&format=json")
                    lTrackdata = lTrackResponse.json()
                    print(artist_name)
                    s2 =json.dumps(lTrackdata)
                    d3 = json.loads(s2)
                    try:
                        print("output:"+d3['artist']['stats']['listeners'])
                        datawriter.writerow([artist_name, d3['artist']['stats']['listeners'], d3['artist']['stats']['playcount'], d3['artist']['tag']])
                        print(artist_name+"done\n")
                    except KeyError:
                        print ('I got a KeyError ')
                    

if __name__=="__main__":
    #getUser()
    #getFriends()
    #getRecentTracks()
    #getLovedTracks()
    getArtistDetails()

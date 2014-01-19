from app import db


ROLE_USER = 0
ROLE_ADMIN = 1

FULL_ACESSIBILITY = 0
PARTIAL_ACESSIBILITY = 1
NO_ACESSIBILITY = 2
UNKNOWN_ACESSIBILITY = 3


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nickname = db.Column(db.String(64), index=True, unique=True)
    email = db.Column(db.String(120), index=True, unique=True)
    role = db.Column(db.SmallInteger, default=ROLE_USER)
    comments = db.relationship('PlaceComments', backref='User',
                               lazy='dynamic')

    def __repr__(self):
        return '<User %r>' % (self.nickname)


class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    name = db.Column(db.String(255), index=True, unique=True)

    def __repr__(self):
        return '<User %r>' % (self.name)


class AccessiblePlace(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    name = db.Column(db.String(255), index=True, unique=True)
    description = db.Column(db.Text)
    photo_path = db.Column(db.String(255))
    latitude = db.Column(db.Integer)
    longitude = db.Column(db.Integer)
    acessibility_level = db.Column(db.SmallInteger, index=True,
                                   default=UNKNOWN_ACESSIBILITY)
    comments = db.relationship('PlaceComments', backref='AccessiblePlace',
                               lazy='dynamic')

    def __repr__(self):
        return '<User %r>' % (self.name)


class PlaceComments(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    acessible_place_id = db.Column(db.Integer,
                                   db.ForeignKey('acessible_place.id'))
    text = db.Column(db.Text)

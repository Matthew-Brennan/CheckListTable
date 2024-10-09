public with sharing class customLookupCell {
    public customLookupCell() {

    }

    public User userLookup(){
        return [SELECT Name, MediumPhotoUrl
                FROM User
                WHERE IsActive = true ];
    }
}
import ballerina/http;

http:OAuth2RefreshTokenGrantConfig activitiesConfig = {
    refreshToken,
    refreshUrl: tokenEndpoint,
    clientId,
    clientSecret,
    clientConfig: {secureSocket: {cert: "resources/public.crt"}}
};

http:ClientAuthConfig insureConfig = {
    username: "alice",
    password: "123"
};

# Calculates gift type from total steps
# + steps - Total steps
# + return - `Types` if a creteria is met
public function giftTypeFromScore(int steps) returns Types? {
    if steps >= SILVER_BAR && steps < GOLD_BAR {
        return SILVER;
    }
    if steps >= GOLD_BAR && steps < PLATINUM_BAR {
        return GOLD;
    }
    if steps >= PLATINUM_BAR {
        return PLATINUM;
    }
    return;
}

function findTheGiftSimple(string userID, string 'from, string to) returns Gift|error {
    final http:Client fifitEp = check new ("https://localhost:9091/activities", auth = activitiesConfig, secureSocket = {
        cert: "resources/public.crt"
    });
    
    Activities activites = check fifitEp->get(string `/steps/user/${userID}/from/${'from}/to/${to}`);
    int steps = 0;
    foreach var activity in activites.activities\-steps {
        steps += activity.value;
    }

    Types? giftType = giftTypeFromScore(steps);
    if giftType is () {
        return {eligible: false, 'from, to, score: steps};
    }
    GiftDetails giftDetails = {'type: giftType, message: string `Congratulations! You have won the ${giftType} gift!`};
    Gift gift = {eligible: true, 'from, to, score: steps, details: giftDetails};
    return gift;
}

function findTheGiftComplex(string userID, string 'from, string to) returns Gift|error {
    final http:Client insureEveryoneEp = check new ("https://localhost:9092/insurance", auth = insureConfig, secureSocket = {
        cert: "resources/public.crt"
    });
    Gift oldGift = check findTheGiftSimple(userID, 'from, to);
    record {|record {int age;} user;|} res = check insureEveryoneEp->get(string `/user/${userID}`);
    int age = res.user.age;
    int score = oldGift.score / ((100 - age) / 10);

    Types? giftType = giftTypeFromScore(score);
    if giftType is () {
        return {eligible: false, 'from, to, score};
    }

    GiftDetails giftDetails = {'type: giftType, message: string `Congratulations! You have won the ${giftType} gift!`};
    Gift gift = {eligible: true, 'from, to, score, details: giftDetails};
    return gift;
}

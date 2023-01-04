// If you want to add a official default language, contact me on discord: https://linventif.fr/discord

local languages = {
    ["french"] = {
        ["close"] = "Fermer",
        ["unknown"] = "Inconnue",
        ["cancel"] = "Annuler",
        ["add_friends"] = "Ajouter en Ami"
        ["confirm"] = "Confirmer",
        ["friends_list"] = "Liste des Amis",
        ["friends_wait"] = "Demande d'Amis en Attente",
        ["friends_list_short"] = "Liste d'Amis",
        ["friends_wait_short"] = "En Attente",
        ["remove"] = "Retirer",
        ["remove_confirm_1"] = "Voulez-vous vraiment retirer ce",
        ["remove_confirm_2"] = "joueur de votre liste d'amis ?",
        ["accept"] = "Accepter",
        ["refuse"] = "Refuser",
        ["no_friends"] = "Vous n'avez aucun ami",
        ["no_request"] = "Vous n'avez aucune demande",
        ["settings"] = "Paramètres",
        ["in_dev"] = "Fonctionnalité en cours de développement !",
        ["request_received"] = "Vous avez reçu une demande d'amis !",
        ["already_friend"] = "Vous êtes déjà amis avec cette personne !",
        ["already_request"] = "Vous avez déjà envoyé une demande d'amis à cette personne !",
        ["request_send"] = "Vous avez envoyé une demande d'amis à ",
        ["request_receive"] = " vous a envoyé une demande d'amis !,",
        ["no_request"] = "Vous n'avez pas reçu de demande d'amis de cette personne !",
        ["request_refused"] = "Vous avez refusé la demande d'amis de ",
        ["request_accept"] "Vous avez accepté la demande d'amis de ",
        ["accept_request"] =  " a accepté votre demande d'amis !",
        ["decline_request"] = " a refusé votre demande d'amis !",
        ["remove_friend"] = " a retiré de sa liste d'amis !",
        ["remove_friend_you"] = "Vous avez retiré ",
        ["remove_friend_you_2"] = " de votre liste d'amis !",
        ["not_friend"] = "Vous n'êtes pas amis avec cette personne !"
    },
}

// Do not edit below this line !!
function FriendsSys:GetTrad(id)
    return languages[FriendsSys.Config.Language][id] || languages["english"][id] || id
end
define(['jquery',
  'templates/team-card.html'
], ($, template_team_card) ->
    team = [
        {
            name:'אדם קריב',
            avatar:'cd511289b5773fff5e7efe328846eef3',
            email:'adam kruchit obudget.org',
            twitter:'ikramvada',
            website:null
        },
        {
            name:'מושון זר-אביב',
            avatar:'b3458a2e3eed95ba26ecca523397e06a',
            email:null,
            twitter:'mushon',
            website:'http://mushon.com'},
        {
            name:'סער אלון-ברקת',
            avatar:'8a1ae50e012e3a5d6accfe9fe6ebd0f2',
            email:null,
            twitter:null,
            website:null
        },
        {
            name:'ניר בט',
            avatar:'9b5b5ecb1cebb8cb3d7294c04a5f68d2',
            email:null,
            twitter:null,
            website:null
        },
        {
            name:'יונתן נאור',
            avatar:'e2ce5192a9e72ebb7effebf3ba3ba025',
            email:null,
            twitter:null,
            website:null
        }
    ]
    teamModalBody = $("#teamModal").find(".modal-body")
    for member, _i in team
        if (_i % 4 ==  0)
            row = teamModalBody.append("<div class='row'></div>")
        row.append(template_team_card(member));
)

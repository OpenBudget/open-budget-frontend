import SingleChangeGroupView from 'Hasadna/oBudget/Pages/Transfer/SingleChangeGroupView';
import { changeExplanation as fetchChangeExplanation, changeGroup as fetchChangeGroup }
  from 'Hasadna/oBudget/Misc/dataFetchers';

export default class Main {
  constructor(changeGroupId, budgetYear, pageWithTourReadyResolve) {
    this.pageWithTourReadyResolve = pageWithTourReadyResolve;
    this.view = new SingleChangeGroupView();

    Promise.all([
      fetchChangeExplanation(changeGroupId, budgetYear),
      fetchChangeGroup(changeGroupId, budgetYear),
    ])
    .then(([changeGroupExplanation, changeGroup]) => {
      this.view.render(changeGroupExplanation, changeGroup);
      this.pageWithTourReadyResolve();
    });
  }

  getView() {
    return this.view;
  }

  afterAppend() {

  }
}
// @on 'change:changeGroupId', ->
//   @changeGroup = new ChangeGroup(null, pageModel: @)
//   @changeGroupExplanation =
//   new ChangeExplanation(year: @get('year'), req_id: @get('changeGroupId'))
//   @readyEvents.push (new ReadyAggregator(@, "ready-changegroup")
//                                 .addModel(@changeGroup))
//   @changeGroup.doFetch()
//   @changeGroupExplanation.doFetch()
//   @changeGroup.on 'change:title_template', =>
//         title_template = @changeGroup.get('title_template')
//         title_template = title_template.split('-')
//         for part in title_template
//           @addKind(part)

// @on 'change:kinds', =>
//     for kind in @get('kinds')
//         $('body').toggleClass("kind-#{kind}",true)

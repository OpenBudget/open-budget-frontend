import $ from 'jquery';
import Backbone from 'backbone';
import _ from 'underscore';
import ControlsView from 'Hasadna/oBudget/Pages/Exemptions/ControlsView';
import ExemptionsView from 'Hasadna/oBudget/Pages/Exemptions/ExemptionsView';
import EntityDetailsView from 'Hasadna/oBudget/Pages/Exemptions/EntityDetailsView';
import dataHelpers from 'Hasadna/oBudget/Pages/Exemptions/dataHelpers';
import NewSpendingsCollection from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/NewSpendings';
import tplInitialLoader from 'Hasadna/oBudget/Pages/Exemptions/initial-loader.hbs';

export default class Main extends Backbone.View {
  start(options) {
    this.baseURL = options.baseURL;

    if (options.entityId) {
      return this.standaloneEntity(options.entityId, options.publicationId);
    }

    return this.spendingsPage();
  }

  spendingsPage() {
    this.newSpendingsCollection = new NewSpendingsCollection([], { baseURL: this.baseURL });

    this.uiModel = new Backbone.Model({
      loadingExemptions: false,
      loadingEntity: false,
      ministriesList: [],

      controls: {
        timeFrame: 7,
        ministry: '',
        orderBy: 'total_flags',
        orderByDirection: 1,
        freeText: '',
      },

      exemptionsToDisplay: [],
    });

    this.initialLoader = $(tplInitialLoader());
    this.initialLoader.appendTo('#spendings-page-article');

    this.controlsView = new ControlsView({ model: this.uiModel });
    this.controlsView.$el.appendTo('#spendings-page-article');
    this.listenTo(this.controlsView, 'values', this.controlsChange);

    const exemptionsView = new ExemptionsView({
      collection: this.newSpendingsCollection,
      model: this.uiModel,
    });

    exemptionsView.$el.appendTo('#spendings-page-article');

    this.listenTo(exemptionsView, 'exemption-selected', this.exemptionSelected);

    const entityDetails = new EntityDetailsView({ model: this.uiModel, baseURL: this.baseURL });

    entityDetails.$el.appendTo('#spendings-page-article');

    return this.newSpendingsCollection.fetchSplit().then(() => {
      this.populateMinistriesList();
      this.controlsView.render();
      this.populateExemptionsToDisplay();
      return this.initialLoader.remove();
    });
  }

  exemptionSelected(entityId, publicationId) {
    return this.uiModel.set({ entityId, publicationId });
  }

  controlsChange(controlsValues) {
    this.uiModel.set({ controls: controlsValues, loadingExemptions: true });
    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(() => {
        this.populateExemptionsToDisplay();
      });
    });
  }

  populateMinistriesList() {
    let rawMinistriesList = this.newSpendingsCollection
                              .map((exemption) => exemption.get('publisher'));

    rawMinistriesList = _.uniq(rawMinistriesList);

    this.ministriesAliasesIndex = dataHelpers.generateAliasesIndex(rawMinistriesList);

    return this.uiModel.set('ministriesList', Object.keys(this.ministriesAliasesIndex).sort());
  }


  populateExemptionsToDisplay() {
    let exemptionsToDisplay = this.newSpendingsCollection
      .filter(dataHelpers.composeExemptionsFilterFunc(
        this.uiModel.get('controls'),
        this.ministriesAliasesIndex
      ))
      .map((exemption) => exemption.toJSON());

    exemptionsToDisplay.sort(dataHelpers.composeExemptionsSortFunc(this.uiModel.get('controls')));

    exemptionsToDisplay = exemptionsToDisplay.slice(0, 300);

    this.uiModel.set('publicationId', null, { silent: true });
    return this.uiModel.set({ exemptionsToDisplay, loadingExemptions: false });
  }

  standaloneEntity(entityId, publicationId) {
    this.uiModel = new Backbone.Model({
      entityId,
      publicationId,
    });

    const entityDetails = new EntityDetailsView({ model: this.uiModel, baseURL: this.baseURL });
    entityDetails.$el.removeClass('col-sm-9');

    return entityDetails.$el.appendTo('#entity-article');
  }
}

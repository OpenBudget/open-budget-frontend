import moment from 'vendor/moment';
import Backbone from 'backbone';

export default class SpendingLine extends Backbone.Model {

  defaults() {
    return {
      entity_id: null,
      budget_code: null,
      supplier_id: null,
      decision: null,
      regulation: null,
      subjects: [],
      supplier: null,
      start_date: null,
      entity_kind: null,
      description: null,
      end_date: null,
      volume: 0,
      reason: null,
      documents: [],
      contact_email: null,
      last_update_date: null,
      publisher: null,
      url: null,
      claim_date: null,
      publication_id: null,
      contact: null,
      history: [],
    };
  }

  parse(response) {
    const ret = response;

    // "20/11/2015"
    ret.last_update_date = moment(ret.last_update_date, 'D/M/YYYY').toDate();

    if (ret.claim_date) {
      // "20/11/2015"
      ret.claim_date = moment(ret.claim_date, 'D/M/YYYY').toDate();
    }

    // "2015-11-21T13:11:14.256340"
    ret.last_modified = moment(ret.last_modified, 'YYYY-MM-DDTHH:mm:ss.SSSS').toDate();

    // "05/11/2015"
    ret.start_date = ret.start_date ? moment(ret.start_date, 'D/M/YYYY').toDate() : null;

    // "31/12/2015"
    ret.end_date = ret.end_date ? moment(ret.end_date, 'D/M/YYYY').toDate() : null;

    // rules for display of sum and flag
    ret.exemption_not_yet_approved = ret.decision === 'טרום החלטת ועדה';

    ret.exemption_null_volume = ret.volume === '';

    ret.exemption_regulation_rule = ret.regulation.indexOf('התקשרות המשך') !== -1;


    return ret;
  }
}

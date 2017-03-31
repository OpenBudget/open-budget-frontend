import $ from 'jquery';
import _ from 'underscore';
import Backbone from 'backbone';
import segmentTree from 'segment-tree-browser';
import tplWidgetChangeTooltip from 'templates/widget-change-tooltip.html';
import tplParticipantPhoto from 'templates/participant-photo.hbs';
import tplWidgetParticipantTooltip from 'templates/widget-participant-tooltip.html';
import tplParticipantTerm from 'templates/participant-term.html';

const d3 = window.d3 || d3; // eslint-disable-line no-use-before-define
const changeClass = window.changeClass || changeClass; // eslint-disable-line no-use-before-define

const TOP_PART_SIZE = 200;
const TICKS = 10;
const TOOLTIP_SIZE = 50;
const YEAR_LINE_HANG_LENGTH = 46;
// const CHANGE_LINE_HANG_LENGTH = 18;

export default class IndepthWidget extends Backbone.View {
  initialize(options) {
    this.options = options;
    this.options.selectionModel.on('change:selection', () => this.render());

    window.addEventListener('resize', () => this.render());

    this.$el.html('');
    this.svg = d3.select(this.el).append('svg').attr('width', '100%').attr('height', '100%');
    this.chart = this.svg.append('g').attr('class', 'chart');
    this.bars = this.svg.append('g').attr('class', 'bar');
    let that = this;
    this.drag = d3.behavior.drag().on('drag', () => {
      const selectionOrig = that.options.selectionModel.get('selection');
      const selection = selectionOrig.slice(0, 2);
      // const { x } = d3.event;
      // const newX = that.baseTimeScale.invert(x);
      let { dx } = d3.event;
      dx = that.baseTimeScale.invert(dx) - that.baseTimeScale.invert(0);

      if (selection[0] - dx > that.model.minTime && selection[1] - dx < that.model.maxTime) {
        selection[0] -= dx;
        selection[1] -= dx;
        return that.options.selectionModel.set('selection', selection);
      }

      return '';
    });

    this.tooltipYOffset = function h(d) {
      return -TOOLTIP_SIZE + 45 + this.valueScale(d.get('value'));
    };

    this.change_tip = d3.tip().attr('class', 'd3-tip timeline-tip')
      .direction(() => 'n').offset(d => [
        this.tooltipYOffset(d),
        0,
      ]).html(p => {
        const d = p;

        d.budgetCode = this.options.budgetCode;
        if (d.get('source') !== 'dummy') {
          return tplWidgetChangeTooltip(d);
        }

        return '';
      });
    this.chart.call(this.change_tip);
    that = this;
    this.showTip = function h(d) {
      const hook = d3.select(this);
      that.change_tip.show(d);
      $('.timeline-tip').toggleClass('active', true).css('pointer-events', 'none');
      that.tipBG.style('opacity', 1);
      for (const a of [
        'x',
        'y',
        'width',
        'height',
      ]) {
        that.tipBG.attr(a, hook.attr(a));
      }
      that.tipBGleft.attr('width', hook.attr('x'));
      that.tipBGright.attr('x', parseInt(hook.attr('x'), 10) + parseInt(hook.attr('width'), 10));
      return true;
    };

    this.hideTip = function (d) {
      that.change_tip.hide(d);
      that.tipBG.style('opacity', 0.1);
      $('.timeline-tip').toggleClass('active', false);
      return true;
    };
    this.showGuideline = function () {
      const hook = d3.select(this);
      const mouse = d3.mouse(this);
      that.chart.selectAll('.guideline').attr('x1', mouse[0]).attr('x2', mouse[0])
        .style('visibility', 'visible');
      let date = that.baseTimeScale.invert(mouse[0]);
      date = new Date(date);
      const ofs = $(that.svg[0]).offset();
      that.participantThumbnailsOffset = that.participantThumbnails.offset();
      if (that.termSegmentTree) {
        const termList = that.termSegmentTree
          .queryPoint(that.baseInverseTimeScale(d3.event.pageX + 4));
        $('.guide-line-photo').remove();
        $('.participant-hide-photo').removeClass('participant-hide-photo');
        for (const term of Array.from(termList)) {
          const participant = term.data;
          that.participantThumbnails.find(`#participant-${participant.get('unique_id')}`)
            .addClass('participant-hide-photo');
          $(tplParticipantPhoto(participant.attributes)).css({
            left: `${d3.event.pageX}px`,
            top: `${that.titleIndexScale(participant.get('title'))}`
            + `${that.participantThumbnailsOffset.top - 240}px`,
          }).appendTo('body');
        }
      }

      d3.select('#indepth-guideline-date')
        .html(`${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`)
        .style('display', 'block')
        .style('left', `${d3.event.pageX}px`)
        .style('top', `${ofs.top + that.valueScale(0)}px`);

      if (this.tagName === 'rect') {
        const hookOfs = mouse[0] - hook.attr('x');
        const hookWidth = hook.attr('width');
        let compensation = hookOfs - hookWidth / 2;
        let subCompensation = 0;
        const tipWidth = $('.timeline-tip').width();
        let overflow = mouse[0] - tipWidth / 2;
        if (overflow < 0) {
          compensation -= overflow;
          subCompensation = overflow;
        }
        overflow = mouse[0] + tipWidth / 2 - that.maxWidth;
        if (overflow > 0) {
          compensation -= overflow;
          subCompensation = overflow;
        }
        $('.timeline-tip').css('margin-left', `${compensation}px`);
        const { sheet } = document.getElementById('arrow-helper');
        while (sheet.cssRules.length > 0) {
          sheet.deleteRule(0);
        }

        if (subCompensation !== 0) {
          sheet
            .insertRule('.timeline-tip .arrow.arrow-bottom:before '
              + `{ margin-left: ${subCompensation - 8}px }`);
          sheet
            .insertRule('.timeline-tip .arrow.arrow-bottom:after ' +
               `{ margin-left: ${subCompensation - 5}px }`);
        }
      }
      return d3.event.preventDefault();
    };
    this.hideGuideline = function h() {
      that.chart.selectAll('.guideline').style('visibility', 'hidden');
      d3.select('#indepth-guideline-date').html('').style('display', 'none');
      $('.guide-line-photo').remove();
      $('.participant-hide-photo').removeClass('participant-hide-photo');
      return true;
    };
    this.scrollToChange = function h(d) {
      const source = d.get('source');
      const uniqueId = source.get('uniqueId');
      const $target = $(`#${uniqueId}`);
      $('html, body')
        .animate({
          scrollTop: $target.offset().top - $('#affix-header').height(),
        },
        1000,
        () => $target.animate({ 'background-color': '#efefef' }, 200)
          .animate({ 'background-color': 'white' }, 200));
      return true;
    };

    this.participants = [];
    this.titles = [];
    this.titleToIndex = {};

    return this.titleToIndex;
  }

  renderChartBg() {
    this.chart.selectAll('.background').data([1]).enter()
      .append('rect').attr('class', 'background').style('stroke', null);
    this.chart.selectAll('.background').data([1])
      .attr('x', () => this.timeScale(this.minTime)).attr('y', () => this.valueScale(this.maxValue))
      .attr('width', () => this.timeScale(this.maxTime) - this.timeScale(this.minTime))
      .attr('height', () => this.valueScale(this.minValue) - this.valueScale(this.maxValue));

    if (!this.tipBG) {
      this.tipBG = this.chart.append('rect').style('fill', '#fff');
      this.tipBGleft = this.chart.append('rect')
        .style('fill', '#ccc')
        .style('opacity', 0.05).attr('y', 0)
        .attr('height', TOP_PART_SIZE).attr('x', 0);

      this.tipBGright = this.chart.append('rect')
        .style('fill', '#ccc').style('opacity', 0.05)
        .attr('y', 0).attr('height', TOP_PART_SIZE)
        .attr('x', 0).attr('width', 10000);
    }

    const allLabelIndexes = _.map([
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
    ], (x) => {
      const r = {
        index: x,
        major: (this.minValue + x * this.tickValue) % this.labelValue < 1,
      };

      return r;
    });

    this.chart.selectAll('.graduationLine')
      .data(allLabelIndexes).enter()
      .append('line').attr('class', d => `graduationLine ${d.major ? 'major' : 'minor'}`);

    this.chart.selectAll('.graduationLine').data(allLabelIndexes)
      .attr('x1', () => this.timeScale(this.minTime))
      .attr('x2', () => this.timeScale(this.maxTime))
      .attr('y1', d => this.valueScale(this.minValue + d.index * this.tickValue))
      .attr('y2', d => this.valueScale(this.minValue + d.index * this.tickValue));

    const graduationLabels = this.chart.selectAll('.graduationLabel')
      .data(_.filter(allLabelIndexes, x => x.major));

    return graduationLabels.enter().append('text')
      .attr('class', 'graduationLabel').attr('x', () => this.timeScale(this.minTime))
      .attr('y', d => this.valueScale(this.minValue + d.index * this.tickValue))
      .attr('dx', 10).attr('dy', -1)
      .style('font-size', 8).style('text-anchor', 'end')
      .text(d => this.formatNumber(this.minValue + d.index * this.tickValue));
  }

  renderGuideline() {
    this.chart.selectAll('.guideline').data([
      {
        w: 3,
        s: '#fff',
      },
      {
        w: 1,
        s: '#000',
      },
    ]).enter().append('line').attr('class', 'guideline')
      .attr('y1', 0).attr('y2', this.$el.height()).style('stroke', d => d.s)
      .style('stroke-width', d => d.w).style('pointer-events', 'none');

    d3.select('body').selectAll('#indepth-guideline-date').data([1])
      .enter().append('div').attr('id', 'indepth-guideline-date');

    this.svg.on('mousemove', this.showGuideline);

    return this.svg.on('mouseout', this.hideGuideline);
  }

  renderYearStarts() {
    const yearstartModels = _.filter(this.model.models, x => x.get('kind') === 'yearstart');
    const newGraphParts = this.chart.selectAll('.graphPartYearStart')
      .data(yearstartModels).enter().append('g').attr('class', 'graphPartYearStart');
    newGraphParts.append('line').attr('class', 'yearstartLine').datum(d => d);
    newGraphParts.append('text').attr('class', 'yearstartLabel').style('font-size', 12)
      .attr('dx', 3).text(d => d.get('date').getFullYear())
      .style('text-anchor', 'end').datum(d => d);

    this.chart.selectAll('.yearstartLine').data(yearstartModels).attr('class', 'yearstartLine')
      .attr('x1', d => this.timeScale(d.get('timestamp')))
      .attr('x2', d => this.timeScale(d.get('timestamp')))
      .attr('y1', d => this.valueScale(d.get('value')))
      .attr('y2', () => this.valueScale(this.minValue) + YEAR_LINE_HANG_LENGTH);

    return this.chart.selectAll('.yearstartLabel').data(yearstartModels)
      .attr('x', d => this.timeScale(d.get('timestamp')))
      .attr('y', () => this.valueScale(this.minValue) + YEAR_LINE_HANG_LENGTH);
  }

  renderApprovedBudgets() {
    const approvedModels = _.filter(this.model.models, x => x.get('kind') === 'approved');
    const newGraphParts = this.chart.selectAll('.graphPartApproved')
      .data(approvedModels).enter()
      .append('g').attr('class', 'graphPartApproved');

    newGraphParts.append('line').attr('class', 'approvedLine').datum(d => d);
    newGraphParts.append('line').attr('class', 'approvedBar').datum(d => d);

    d3.select('#approvedTooltips').selectAll('.approvedTip').data(approvedModels)
      .enter().append('div').attr('class', 'approvedTip participantTooltip')
      .html(d => tplWidgetParticipantTooltip({
        participants: d.get('participants'),
        _,
      }));

    d3.select('#approvedTooltips').selectAll('.approvedTip').data(approvedModels)
      .style('left', d => `${this.timeScale(d.get('timestamp'))}px`).style('top', '0px');
    return this.chart.selectAll('.approvedBar').data(approvedModels)
      .attr('x1', d => this.timeScale(d.get('timestamp')))
      .attr('x2', d => this.timeScale(d.get('timestamp') + d.get('width')))
      .attr('y1', d => this.valueScale(d.get('value')))
      .attr('y2', d => this.valueScale(d.get('value')));
  }

  renderRevisedBudgets() {
    const revisedModels = _.filter(
      this.model.models, x => x.get('kind') === 'revised' && !x.get('disabled'));

    const newGraphParts = this.chart.selectAll('.graphPartRevised')
      .data(revisedModels).enter().append('g')
      .attr('class', 'graphPartRevised');
    newGraphParts.append('line').attr('class', 'revisedBar').datum(d => d);

    return this.chart.selectAll('.revisedBar').data(revisedModels)
      .attr(
        'class',
        (d) => {
          const dby = d.get('diff_baseline');
          let p;

          if (dby < 0) {
            p = 'revisedBar reduce';
          } else {
            p = (dby > 0 ? 'revisedBar increase' : 'revisedBAr');
          }

          return p;
        }
      )
      .attr('x1', d => this.timeScale(d.get('timestamp') - d.get('width')))
      .attr('x2', d => this.timeScale(d.get('timestamp')))
      .attr('y1', d => this.valueScale(d.get('original_baseline')))
      .attr('y2', d => this.valueScale(d.get('value')));
  }

  renderChangeItems() {
    let cls;
    let subkind;
    const changeModels = _.filter(this.model.models, x => x.get('kind') === 'change');
    const lastChanges = _.filter(changeModels, x => x.get('last'));
    this.chart.selectAll('.changeBar-last').data(lastChanges)
      .enter().append('rect').attr('class', 'changeBar-last').datum(d => d);
    this.chart.selectAll('.changeBar-last-line').data(lastChanges)
     .enter().append('line').attr('class', 'changeBar-last-line').datum(d => d);
    const newGraphParts = this.chart.selectAll('.graphPartChanged')
      .data(changeModels).enter().append('g').attr('class', 'graphPartChanged');
    newGraphParts.append('line').attr('class', 'changeBar').datum(d => d);
    newGraphParts.append('line').attr('class', 'changeLine').datum(d => d);
    newGraphParts.append('line').attr('class', 'changeLineWaterfall').datum(d => d);
    this.chart.selectAll('.changeBar-last').data(lastChanges)
      .attr(
        'class',
        d => {
          cls = changeClass(d.get('original_baseline'), d.get('value'));
          subkind = d.get('subkind');// `changeBar-last ${cls} ${subkind}`;
          return `changeBar-last ${cls} ${subkind}`;
        }
      )
      .attr('x', d => this.timeScale(this.roundToYearStart(d.get('timestamp'))))
      .attr(
        'width',
        d => this.timeScale(d.get('timestamp') + d.get('width')) -
          this.timeScale(this.roundToYearStart(d.get('timestamp')))
      )
      .attr('y', d => this.valueScale(d.get('value'))).attr('height', d => this.valueScale(this.minValue) - this.valueScale(d.get('value')));
    this.chart.selectAll('.changeBar-last-line').data(lastChanges)
      .attr('class', d => (cls = changeClass(d.get('original_baseline'), d.get('value')), subkind = d.get('subkind'), `changeBar-last-line ${cls} ${subkind}`)).attr('x1', d => this.timeScale(this.roundToYearStart(d.get('timestamp')))).attr('x2', d => this.timeScale(d.get('timestamp'))).attr('y1', d => this.valueScale(d.get('value'))).attr('y2', d => this.valueScale(d.get('value')));
    this.chart.selectAll('.changeBar').data(changeModels).attr('class', d => (cls = changeClass(d.get('original_baseline'), d.get('value')), subkind = d.get('subkind'), `changeBar ${cls} ${subkind}`)).attr('x1', d => this.timeScale(d.get('timestamp'))).attr('x2', d => this.timeScale(d.get('timestamp') + d.get('width'))).attr('y1', d => this.valueScale(d.get('value'))).attr('y2', d => this.valueScale(d.get('value')));
    this.chart.selectAll('.changeLine').data(changeModels).attr('class', d => (cls = changeClass(d.get('original_baseline'), d.get('value')), subkind = d.get('subkind'), `changeLine ${cls} ${subkind}`)).attr('x1', d => this.timeScale(d.get('timestamp'))).attr('x2', d => this.timeScale(d.get('timestamp'))).attr('y1', d => this.valueScale(d.get('value') + _.min([
      0,
      d.get('diff_value'),
    ]) * (d.get('diff_value') > 0 ? 1 : 0))).attr('y2', d => this.valueScale(this.minValue)).attr('stroke-width', 5).style('opacity', 0.3).style('stroke-dasharray', '1,2');
    return this.chart.selectAll('.changeLineWaterfall').data(changeModels).attr('class', d => (cls = changeClass(d.get('original_baseline'), d.get('value')), subkind = d.get('subkind'), `changeLineWaterfall ${cls} ${subkind}`)).attr('x1', d => this.timeScale(d.get('timestamp'))).attr('x2', d => this.timeScale(d.get('timestamp'))).attr('y1', d => this.valueScale(d.get('value') - d.get('diff_value')) + 1 * (d.get('diff_value') > 0 ? 1 : -1)).attr('y2', d => this.valueScale(d.get('value')) - 1 * (d.get('diff_value') > 0 ? 1 : -1)).attr('stroke-width', 5);
  }

  renderUsedBudgets() {
    const usedModels = _.filter(this.model.models, x => x.get('kind') === 'used');
    const newGraphParts = this.chart.selectAll('.graphPartUsed').data(usedModels).enter().append('g').attr('class', 'graphPartUsed');
    newGraphParts.append('line').attr('class', 'usedBar').datum(d => d);
    newGraphParts.append('line').attr('class', 'usedLine').datum(d => d);
    newGraphParts.append('text').attr('class', 'usedLabel').style('font-size', 12).attr('dx', -3).text(d => d.get('date').getFullYear()).style('text-anchor', 'start').datum(d => d);
    this.chart.selectAll('.usedBar').data(usedModels).attr('x1', d => this.timeScale(d.get('timestamp') - 9 * d.get('width'))).attr('x2', d => this.timeScale(d.get('timestamp') + d.get('width'))).attr('y1', d => this.valueScale(d.get('value'))).attr('y2', d => this.valueScale(d.get('value')));
    this.chart.selectAll('.usedLine').data(usedModels).attr('x1', d => this.timeScale(d.get('timestamp'))).attr('x2', d => this.timeScale(d.get('timestamp'))).attr('y1', d => this.valueScale(d.get('value'))).attr('y2', d => this.valueScale(this.minValue) + YEAR_LINE_HANG_LENGTH);
    return this.chart.selectAll('.usedLabel').data(usedModels).attr('x', d => this.timeScale(d.get('timestamp'))).attr('y', d => this.valueScale(this.minValue) + YEAR_LINE_HANG_LENGTH);
  }
  renderTooltipHooks() {
    let allModels, ret;
    if (this.show_changes) {
      allModels = _.filter(this.model.models, m => m.get('kind') === 'used' || m.get('kind') === 'change' && m.get('src') === 'changeline' || m.get('kind') === 'approved');
    } else {
      allModels = _.filter(this.model.models, m => m.get('kind') === 'used' || m.get('kind') === 'approved');
    }
    const newGraphParts = this.chart.selectAll('.tooltipHook').data(allModels).enter().append('g').attr('class', 'tooltipHook');
    newGraphParts.append('rect').style('stroke-width', 0).style('fill', '#000').style('opacity', 0).datum(d => d);
    const get_width = d => {
      ret = d3.max([
        this.timeScale(d.get('timestamp') + d.get('width')) - this.timeScale(d.get('timestamp')),
        10,
      ]);
      return ret;
    };
    const get_x = d => {
      const z = (this.timeScale(d.get('timestamp') + d.get('width')) - this.timeScale(d.get('timestamp')) - 10) / 2;
      const ofs = d3.min([
        0,
        z,
      ]);
      ret = this.timeScale(d.get('timestamp')) + ofs;
      return ret;
    };
    return this.chart.selectAll('.tooltipHook rect').data(allModels).attr('x', get_x).attr('y', 0).attr('width', get_width).attr('height', '100%').on('mouseenter', this.showTip).on('mouseleave', this.hideTip).on('mousemove', this.showGuideline).on('click', this.scrollToChange);
  }
  render__timeline_titles() {
    return this.titleIndexScale = function (title) {
      return TOP_PART_SIZE + YEAR_LINE_HANG_LENGTH + (this.titleToIndex[title] + 1) * 32;
    };
  }
  render__timeline_terms() {
    const newGroups = this.chart.selectAll('.timelineTerm').data(this.participants).enter().append('g').attr('class', 'timelineTerm');
    newGroups.append('line').attr('class', 'termBreadth');
    newGroups.append('line').attr('class', 'termStart');
    const groups = this.chart.selectAll('.timelineTerm').data(this.participants);
    groups.selectAll('.termBreadth').attr('x1', d => this.timeScale(d.get('start_timestamp'))).attr('x2', d => this.timeScale(d.get('end_timestamp'))).attr('y1', d => this.titleIndexScale(d.get('title'))).attr('y2', d => this.titleIndexScale(d.get('title')));
    groups.selectAll('.termStart').attr('x1', d => this.timeScale(d.get('end_timestamp'))).attr('x2', d => this.timeScale(d.get('end_timestamp'))).attr('y1', d => this.titleIndexScale(d.get('title'))).attr('y2', d => this.titleIndexScale(d.get('title')) + 10);
    const newTumbnails = d3.select('#participantThumbnails').selectAll('.participantThumbnail').data(this.participants).enter();
    if (this.participants.length > 0) {
      let participant;
      this.centerEpoch = this.minTime + (this.maxTime - this.minTime) / 2;
      this.termSegmentTree = new segmentTree();
      for (let index = 0; index < this.participants.length; index++) {
        var endTimestamp;
        participant = this.participants[index];
        const startTimestamp = participant.get('start_timestamp');
        if (participant.get('end_date')) {
          endTimestamp = participant.get('end_timestamp');
        } else {
          endTimestamp = new Date().getTime();
          participant.set('end_timestamp', endTimestamp);
        }
        if (startTimestamp != null && endTimestamp != null && endTimestamp > startTimestamp) {
          this.termSegmentTree.pushInterval(startTimestamp, endTimestamp, participant);
        }
      }
      this.termSegmentTree.buildTree();
      let divs = newTumbnails.append('div').attr('class', 'participantThumbnail');
      const renderParticipant = function (d) {
        if (d.get('end_timestamp') > d.get('start_timestamp')) {
          return participant = tplParticipantTerm(d.attributes);
        }
      };
      divs.html(renderParticipant);
      return divs = d3.select('#participantThumbnails').selectAll('.participantThumbnail').data(this.participants).style('left', d => this.timeScale(d.get('start_timestamp')) + 'px').style('width', d => this.timeScale(d.get('end_timestamp')) - this.timeScale(d.get('start_timestamp')) + 'px').style('top', d => this.titleIndexScale(d.get('title')) - 240 + 'px');
    }
  }
  render__yearly_lines() {
    let start_models = _.filter(this.model.models, m => m.get('kind') === 'yearstart');
    const start_models_starts = start_models.slice(0, -1);
    const start_models_ends = start_models.slice(1);
    start_models = _.zip(start_models_starts, start_models_ends);
    const simpleApprovedLines = this.chart.selectAll('.simpleApprovedLine').data(start_models);
    let news = simpleApprovedLines.enter().append('g').attr('class', d => `simpleApprovedLine ${changeClass(d[0].get('source').get('net_allocated'), d[1].get('source').get('net_allocated'))}`);
    news.append('line');
    news.append('circle').attr('r', 1);
    simpleApprovedLines.selectAll('line').attr('x1', d => this.timeScale(d[0].get('timestamp'))).attr('x2', d => this.timeScale(d[1].get('timestamp'))).attr('y1', d => this.valueScale(d[0].get('source').get('net_allocated'))).attr('y2', d => this.valueScale(d[1].get('source').get('net_allocated')));
    simpleApprovedLines.selectAll('circle').attr('cx', d => this.timeScale(d[1].get('timestamp'))).attr('cy', d => this.valueScale(d[1].get('source').get('net_allocated')));
    let end_models = _.filter(this.model.models, m => m.get('kind') === 'used');
    const end_models_starts = end_models.slice(0, -1);
    const end_models_ends = end_models.slice(1);
    end_models = _.zip(end_models_starts, end_models_ends);
    const simpleUsedLines = this.chart.selectAll('.simpleUsedLine').data(end_models);
    news = simpleUsedLines.enter().append('g').attr('class', d => `simpleUsedLine ${changeClass(d[0].get('source').get('net_used'), d[1].get('source').get('net_used'))}`);
    news.append('line');
    news.append('circle').attr('r', 1);
    simpleUsedLines.selectAll('line').attr('x1', d => this.timeScale(d[0].get('timestamp'))).attr('x2', d => this.timeScale(d[1].get('timestamp'))).attr('y1', d => this.valueScale(d[0].get('source').get('net_used'))).attr('y2', d => this.valueScale(d[1].get('source').get('net_used')));
    simpleUsedLines.selectAll('circle').attr('cx', d => this.timeScale(d[1].get('timestamp'))).attr('cy', d => this.valueScale(d[1].get('source').get('net_used')));
    const simpleRevisedLines = this.chart.selectAll('.simpleRevisedLine').data(end_models);
    news = simpleRevisedLines.enter().append('g').attr('class', d => `simpleRevisedLine ${changeClass(d[0].get('source').get('net_revised'), d[1].get('source').get('net_revised'))}`);
    news.append('line');
    news.append('circle').attr('r', 1);
    simpleRevisedLines.selectAll('line').attr('x1', d => this.timeScale(d[0].get('timestamp'))).attr('x2', d => this.timeScale(d[1].get('timestamp'))).attr('y1', d => this.valueScale(d[0].get('source').get('net_revised'))).attr('y2', d => this.valueScale(d[1].get('source').get('net_revised')));
    return simpleRevisedLines.selectAll('circle').attr('cx', d => this.timeScale(d[1].get('timestamp'))).attr('cy', d => this.valueScale(d[1].get('source').get('net_revised')));
  }
  render() {
    let base;
    this.svg.call(this.drag);
    this.maxWidth = $(this.el).width();
    this.maxHeight = $(this.el).height();
    this.setValueRange();
    this.minTime = this.options.selectionModel.get('selection')[0];
    this.maxTime = this.options.selectionModel.get('selection')[1];
    this.baseTimeScale = d3.scale.linear().domain([
      this.minTime,
      this.maxTime,
    ]).range([
      0,
      this.maxWidth,
    ]);
    this.baseInverseTimeScale = d3.scale.linear().domain([
      0,
      this.maxWidth,
    ]).range([
      this.minTime,
      this.maxTime,
    ]);
    this.roundToYearStart = t => {
      const year = new Date(t).getFullYear();
      base = new Date(year, 0).valueOf();
      return base;
    };
    this.yearSeperatingScale = t => {
      base = this.roundToYearStart(t);
      return base + (t - base) * 0.98;
    };
    this.pixelPerfecter = t => {
      return Math.floor(t) + 0.5;
    };
    const code = this.options.budgetCode;
    this.show_changes = 4 < code.length && code.length < 10;
    if (this.show_changes) {
      this.timeScale = t => {
        return this.pixelPerfecter(this.baseTimeScale(this.yearSeperatingScale(t)));
      };
    } else {
      this.timeScale = t => {
        return this.pixelPerfecter(this.baseTimeScale(t));
      };
    }
    this.inverseTimeScale = t => {
      return this.pixelPerfecter(this.baseInverseTimeScale(t));
    };
    this.baseValueScale = d3.scale.linear().domain([
      this.minValue,
      this.maxValue,
    ]).range([
      TOP_PART_SIZE,
      0,
    ]);
    this.valueScale = t => {
      return this.pixelPerfecter(this.baseValueScale(t));
    };
    this.renderChartBg();
    this.renderYearStarts();
    if (this.show_changes) {
      this.renderApprovedBudgets();
      this.renderRevisedBudgets();
      this.renderChangeItems();
      this.renderUsedBudgets();
    } else {
      this.render__yearly_lines();
    }
    this.renderTooltipHooks();
    this.render__timeline_terms();
    this.render__timeline_titles();
    return this.renderGuideline();
  }
  formatNumber(n) {
    const rx = /(\d+)(\d{3})/;
    return String(Math.floor(n * 1000)).replace(/^\d+/, function (w) {
      while (rx.test(w)) {
        w = w.replace(rx, '$1,$2');
      }
      return w;
    });
  }
  setValueRange() {
    this.valueRange = this.model.maxValue;
    let scale = 1;
    let { valueRange } = this;
    const RATIO = 1 * (TOP_PART_SIZE - TOOLTIP_SIZE) / TOP_PART_SIZE;
    while (valueRange > 1 * RATIO) {
      scale *= 10;
      valueRange /= 10;
    }
    const PARTS = 40;
    const i40 = Math.ceil(valueRange / RATIO * PARTS);
    const i40part = i40 / PARTS;
    const i40labelMult = (1 + i40 % 2) * 2;
    this.tickValue = i40 * scale / (TICKS * PARTS);
    this.labelValue = i40labelMult * this.tickValue;
    this.minValue = 0;
    return this.maxValue = this.minValue + TICKS * this.tickValue;
  }
  setParticipants(participants) {
    let index;
    let title = null;
    this.titles = [];
    const dupDetector = {};
    const dupIndices = [];
    for (index = 0; index < participants.length; index++) {
      const participant = participants[index];
      participant.setTimestamps(this.model.maxTime);
      const unique_id = participant.get('unique_id');
      if (dupDetector[unique_id]) {
        dupIndices.unshift(index);
        continue;
      }
      dupDetector[unique_id] = participant;
      if (participant.get('title') !== title) {
        title = participant.get('title');
        this.titleToIndex[title] = this.titles.length;
        this.titles.push(title);
      }
    }
    for (index of Array.from(dupIndices)) {
      participants.splice(index, 1);
    }
    this.participants = participants;
    this.participantThumbnails = $('#participantThumbnails');
    return this.participantThumbnailsOffset = this.participantThumbnails.offset();
  }
}

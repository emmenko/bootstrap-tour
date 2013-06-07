describe "Bootstrap Tour", ->
  afterEach ->
    @tour.setState("current_step", null)
    @tour.setState("end", null)
    popover = $(".popover")
    if popover.length > 0 then popover.remove()
    $.each(@tour._steps, (i, s) ->
      if s.element? && s.element.popover?
        s.element.popover("hide").removeData("popover")
    )

  it "should set the tour options", ->
    @tour = new Tour({
      name: "test"
      afterSetState: ->
        true
      afterGetState: ->
        true
    })
    expect(@tour._options.name, "options.name is set").to.equal("test")
    assert.ok(@tour._options.afterGetState, "options.afterGetState is set")
    assert.ok(@tour._options.afterSetState, "options.afterSetState is set")

  it "should have default name of 'tour'", ->
    @tour = new Tour()
    expect(@tour._options.name, "tour default name is 'tour'").to.equal("tour")

  it "should accept an array of steps and set the current step", ->
    @tour = new Tour()
    assert.deepEqual(@tour._steps, [], "tour accepts an array of steps")
    assert.strictEqual(@tour._current, 0, "tour initializes current step")

  it "'setState' should save state cookie", ->
    @tour = new Tour()
    @tour.setState("save", "yes")
    assert.strictEqual($.cookie("tour_save"), "yes", "tour saves state cookie")
    $.removeCookie("tour_save")

  it "'getState' should get state cookie", ->
    @tour = new Tour()
    @tour.setState("get", "yes")
    assert.strictEqual(@tour.getState("get"), "yes", "tour gets state cookie")
    $.removeCookie("tour_get")

  it "'setState' should save state localStorage items", ->
    @tour = new Tour({
      useLocalStorage: true
    })
    @tour.setState("test", "yes")
    assert.strictEqual(window.localStorage.getItem("tour_test"), "yes", "tour save state localStorage items")

  it "'getState' should get state localStorage items", ->
    @tour = new Tour({
      useLocalStorage: true
    })
    @tour.setState("test", "yes")
    assert.strictEqual(@tour.getState("test"), "yes", "tour saves state localStorage items")
    window.localStorage.setItem("tour_test", null)

  it "'addStep' should add a step", ->
    @tour = new Tour()
    step = { element: $("<div>").appendTo("#container") }
    @tour.addStep(step)
    assert.deepEqual(@tour._steps, [step], "tour adds the step")

  it "'addSteps' should add multiple step", ->
    @tour = new Tour()
    firstStep = { element: $("<div>").appendTo("#container") }
    secondStep = { element: $("<div>").appendTo("#container") }
    @tour.addSteps([firstStep, secondStep])
    assert.deepEqual(@tour._steps, [firstStep, secondStep], "tour adds multiple steps")

  it "'step' should have an id", ->
    @tour = new Tour()
    $element = $("<div>").appendTo("#container")
    @tour.addStep({element: $element})
    @tour.start()
    assert.strictEqual($element.data("popover").tip().attr("id"), "step-0", "tour runs onStart when the first step shown")

  it "with onStart option should run the callback before showing the first step", ->
    tour_test = 0
    @tour = new Tour({
      onStart: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual(tour_test, 2, "tour runs onStart when the first step shown")

  it "with onEnd option should run the callback after hiding the last step", ->
    tour_test = 0
    @tour = new Tour({
      onEnd: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.end()
    assert.strictEqual(tour_test, 2, "tour runs onEnd when the last step hidden")

  it "with onShow option should run the callback before showing the step", ->
    tour_test = 0
    @tour = new Tour({
      onShow: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual(tour_test, 2, "tour runs onShow when first step shown")
    @tour.next()
    assert.strictEqual(tour_test, 4, "tour runs onShow when next step shown")

  it "with onShown option should run the callback after showing the step", ->
    tour_test = 0
    @tour = new Tour({
      onShown: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual(tour_test, 2, "tour runs onShown after first step shown")

  it "with onHide option should run the callback before hiding the step", ->
    tour_test = 0
    @tour = new Tour({
      onHide: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    assert.strictEqual(tour_test, 2, "tour runs onHide when first step hidden")
    @tour.hideStep(1)
    assert.strictEqual(tour_test, 4, "tour runs onHide when next step hidden")

  it "with onHidden option should run the callback after hiding the step", ->
    tour_test = 0
    @tour = new Tour({
      onHidden: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    assert.strictEqual(tour_test, 2, "tour runs onHidden after first step hidden")
    @tour.next()
    assert.strictEqual(tour_test, 4, "tour runs onHidden after next step hidden")

  it "'addStep' with onShow option should run the callback before showing the step", ->
    tour_test = 0
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({
      element: $("<div>").appendTo("#container")
      onShow: ->
        tour_test = 2 })
    @tour.start()
    assert.strictEqual(tour_test, 0, "tour does not run onShow when step not shown")
    @tour.next()
    assert.strictEqual(tour_test, 2, "tour runs onShow when step shown")

  it "'addStep' with onHide option should run the callback before hiding the step", ->
    tour_test = 0
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({
      element: $("<div>").appendTo("#container")
      onHide: ->
        tour_test = 2
    })
    @tour.start()
    @tour.next()
    assert.strictEqual(tour_test, 0, "tour does not run onHide when step not hidden")
    @tour.hideStep(1)
    assert.strictEqual(tour_test, 2, "tour runs onHide when step hidden")

  it "'getStep' should get a step", ->
    @tour = new Tour()
    step = {
      element: $("<div>").appendTo("#container")
      container: "body"
      path: "test"
      placement: "left"
      title: "Test"
      content: "Just a test"
      id: "step-0"
      prev: -1
      next: 2
      end: false
      animation: false
      backdrop: false
      redirect: true
      onShow: (tour) ->
      onShown: (tour) ->
      onHide: (tour) ->
      onHidden: (tour) ->
      onNext: (tour) ->
      onPrev: (tour) ->
      template: "<div class='popover tour'>
      <div class='arrow'></div>
      <h3 class='popover-title'></h3>
      <div class='popover-content'></div>
      </div>"
    }
    @tour.addStep(step)
    assert.deepEqual(@tour.getStep(0), step, "tour gets a step")

  it "'start' should start a tour", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual($(".popover").length, 1, "tour starts")

  it "'start' should not start a tour that ended", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.setState("end", "yes")
    @tour.start()
    assert.strictEqual($(".popover").length, 0, "previously ended tour don't start again")

  it "'start'(true) should force starting a tour that ended", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.setState("end", "yes")
    @tour.start(true)
    assert.strictEqual($(".popover").length, 1, "previously ended tour starts again if forced to")

  it "'next' should hide current step and show next step", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    assert.strictEqual(@tour.getStep(0).element.data("popover").tip().filter(":visible").length, 0, "tour hides current step")
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour shows next step")

  it "'end' should hide current step and set end state", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.end()
    assert.strictEqual(@tour.getStep(0).element.data("popover").tip().filter(":visible").length, 0, "tour hides current step")
    assert.strictEqual(@tour.getState("end"), "yes", "tour sets end state")

  it "'ended' should return true is tour ended and false if not", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual(@tour.ended(), false, "tour returns false if not ended")
    @tour.end()
    assert.strictEqual(@tour.ended(), true, "tour returns true if ended")

  it "'restart' should clear all states and start tour", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    @tour.end()
    @tour.restart()
    assert.strictEqual(@tour.getState("end"), null, "tour sets end state")
    assert.strictEqual(@tour._current, 0, "tour sets first step")
    assert.strictEqual($(".popover").length, 1, "tour starts")

  it "'hideStep' should hide a step", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.hideStep(0)
    assert.strictEqual(@tour.getStep(0).element.data("popover").tip().filter(":visible").length, 0, "tour hides step")

  it "'showStep' should set a step and show it", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(1)
    assert.strictEqual(@tour._current, 1, "tour sets step")
    assert.strictEqual($(".popover").length, 1, "tour shows one step")
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour shows correct step")

  it "'showStep' should not show anything when the step doesn't exist", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(2)
    assert.strictEqual($(".popover").length, 0, "tour doesn't show any step")

  it "'showStep' should skip step when no element is specified", ->
    @tour = new Tour()
    @tour.addStep({})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(1)
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour skips step with no element")

  it "'showStep' should skip step when element doesn't exist", ->
    @tour = new Tour()
    @tour.addStep({element: "#tour-test"})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(1)
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour skips step with no element")

  it "'showStep' should skip step when element is invisible", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container").hide()})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(1)
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour skips step with no element")

  it "'setCurrentStep' should set the current step", ->
    @tour = new Tour()
    @tour.setCurrentStep(4)
    assert.strictEqual(@tour._current, 4, "tour sets current step if passed a value")
    @tour.setState("current_step", 2)
    @tour.setCurrentStep()
    assert.strictEqual(@tour._current, 2, "tour reads current step state if not passed a value")

  it "'showNextStep' should show the next step", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.showNextStep()
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour shows next step")

  it "'showPrevStep' should show the previous step", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.showStep(1)
    @tour.showPrevStep()
    assert.strictEqual(@tour.getStep(0).element.data("popover").tip().filter(":visible").length, 1, "tour shows previous step")

  it "'showStep' should show multiple step on the same element", ->
    element = $("<div>").appendTo("#container")
    @tour = new Tour()
    @tour.addStep({element: element})
    @tour.addStep({element: element})
    @tour.start()
    assert.strictEqual(@tour.getStep(0).element.data("popover").tip().filter(":visible").length, 1, "tour show the first step")
    @tour.showNextStep()
    assert.strictEqual(@tour.getStep(1).element.data("popover").tip().filter(":visible").length, 1, "tour show the second step on the same element")

  it "should properly verify paths", ->
    @tour = new Tour()

    assert.strictEqual(@tour._isRedirect(undefined, "/"), false, "don't redirect if no path")
    assert.strictEqual(@tour._isRedirect("", "/"), false, "don't redirect if path empty")
    assert.strictEqual(@tour._isRedirect("/somepath", "/somepath"), false, "don't redirect if path matches current path")
    assert.strictEqual(@tour._isRedirect("/somepath/", "/somepath"), false, "don't redirect if path with slash matches current path")
    assert.strictEqual(@tour._isRedirect("/somepath", "/somepath/"), false, "don't redirect if path matches current path with slash")
    assert.strictEqual(@tour._isRedirect("/somepath?search=true", "/somepath"), false, "don't redirect if path with query params matches current path")
    assert.strictEqual(@tour._isRedirect("/somepath/?search=true", "/somepath"), false, "don't redirect if path with slash and query params matches current path")
    assert.strictEqual(@tour._isRedirect("/anotherpath", "/somepath"), true, "redirect if path doesn't match current path")

  it "'getState' should return null after Tour.removeState with null value using cookies", ->
    @tour = new Tour({useLocalStorage: false})
    @tour.setState("test", "test")
    @tour.removeState("test")
    assert.strictEqual(@tour.getState("test"), null, "tour returns null after null setState")

  it "'getState' should return null after Tour.removeState with null value using localStorage", ->
    @tour = new Tour({useLocalStorage: true})
    @tour.setState("test", "test")
    @tour.removeState("test")
    assert.strictEqual(@tour.getState("test"), null, "tour returns null after null setState")

  it "'removeState' should call afterRemoveState callback", ->
    sentinel = false
    @tour = new Tour({afterRemoveState: -> sentinel = true})
    @tour.removeState("current_step")
    assert.strictEqual(sentinel, true, "removeState calls callback")

  it "shouldn't move to the next state until the onShow promise is resolved", ->
    @tour = new Tour()
    deferred = $.Deferred()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container"), onShow: -> return deferred})
    @tour.start()
    @tour.next()
    assert.strictEqual(@tour._current, 0, "tour shows old state until resolving of onShow promise")
    deferred.resolve()
    assert.strictEqual(@tour._current, 1, "tour shows new state after resolving onShow promise")

  it "shouldn't hide popover until the onHide promise is resolved", ->
    @tour = new Tour()
    deferred = $.Deferred()
    @tour.addStep({element: $("<div>").appendTo("#container"), onHide: -> return deferred})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    assert.strictEqual(@tour._current, 0, "tour shows old state until resolving of onHide promise")
    deferred.resolve()
    assert.strictEqual(@tour._current, 1, "tour shows new state after resolving onShow promise")

  it "shouldn't start until the onStart promise is resolved", ->
    deferred = $.Deferred()
    @tour = new Tour({onStart: -> return deferred})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual($(".popover").length, 0, " does not start before onStart promise is resolved")
    deferred.resolve()
    assert.strictEqual($(".popover").length, 1, " starts after onStart promise is resolved")

  it "'reflex' parameter should change the element cursor to pointer when the step is displayed", ->
    $element = $("<div>").appendTo("#container")
    @tour = new Tour()
    @tour.addStep({element: $element, reflex: true})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    assert.strictEqual($element.css("cursor"), "auto", " doesn't change the element cursor before displaying the step")
    @tour.start()
    assert.strictEqual($element.css("cursor"), "pointer", " change the element cursor to pointer when the step is displayed")
    @tour.next()
    assert.strictEqual($element.css("cursor"), "auto", " reset the element cursor when the step is hidden")

  it "'reflex' parameter should change the element cursor to pointer when the step is displayed", ->
    $element = $("<div>").appendTo("#container")
    @tour = new Tour()
    @tour.addStep({element: $element, reflex: true})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    assert.strictEqual($element.css("cursor"), "auto", " doesn't change the element cursor before displaying the step")
    @tour.start()
    assert.strictEqual($element.css("cursor"), "pointer", " change the element cursor to pointer when the step is displayed")
    @tour.next()
    assert.strictEqual($element.css("cursor"), "auto", " reset the element cursor when the step is hidden")

  it "'showStep' redirects to the anchor when the path is an anchor", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container"), path: "#mytest"})
    @tour.showStep(0)
    assert.strictEqual("#mytest", document.location.hash, " step has moved to the anchor")
    document.location.hash = ""

  it "'backdrop' parameter should show backdrop with step", ->
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container"), backdrop: false})
    @tour.addStep({element: $("<div>").appendTo("#container"), backdrop: true})
    @tour.showStep(0)
    assert.strictEqual($(".tour-backdrop").length, 0, "disable backdrop")
    assert.strictEqual($(".tour-step-backdrop").length, 0, "disable backdrop")
    assert.strictEqual($(".tour-step-background").length, 0, "disable backdrop")
    @tour.showStep(1)
    assert.strictEqual($(".tour-backdrop").length, 1, "enable backdrop")
    assert.strictEqual($(".tour-step-backdrop").length, 1, "enable backdrop")
    assert.strictEqual($(".tour-step-background").length, 1, "enable backdrop")
    @tour.end()
    assert.strictEqual($(".tour-backdrop").length, 0, "disable backdrop")
    assert.strictEqual($(".tour-step-backdrop").length, 0, "disable backdrop")
    assert.strictEqual($(".tour-step-background").length, 0, "disable backdrop")

  it "'basePath' should prepend the path to the steps", ->
    @tour = new Tour({
      basePath: 'test/'
    });
    @tour.addStep({element: $("<div>").appendTo("#container"), path: 'test.html'})
    assert.strictEqual(@tour._isRedirect(@tour._options.basePath + @tour.getStep(0).path, 'test/test.html'), false, " adds basePath to step path")

  it "with onNext option should run the callback before showing the next step", ->
    tour_test = 0
    @tour = new Tour({
      onNext: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    assert.strictEqual(tour_test, 2, "tour runs onNext when next step is called")

  it "'addStep' with onNext option should run the callback before showing the next step", ->
    tour_test = 0
    @tour = new Tour()
    @tour.addStep({
      element: $("<div>").appendTo("#container")
      onNext: ->
        tour_test = 2 })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    assert.strictEqual(tour_test, 0, "tour does not run onNext when next step is not called")
    @tour.next()
    assert.strictEqual(tour_test, 2, "tour runs onNext when next step is called")

  it "with onPrev option should run the callback before showing the prev step", ->
    tour_test = 0
    @tour = new Tour({
      onPrev: ->
        tour_test += 2
    })
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.start()
    @tour.next()
    @tour.prev()
    assert.strictEqual(tour_test, 2, "tour runs onPrev when prev step is called")

  it "'addStep' with onPrev option should run the callback before showing the prev step", ->
    tour_test = 0
    @tour = new Tour()
    @tour.addStep({element: $("<div>").appendTo("#container")})
    @tour.addStep({
      element: $("<div>").appendTo("#container")
      onPrev: ->
        tour_test = 2 })
    @tour.start()
    assert.strictEqual(tour_test, 0, "tour does not run onPrev when prev step is not called")
    @tour.next()
    @tour.prev()
    assert.strictEqual(tour_test, 2, "tour runs onPrev when prev step is called")
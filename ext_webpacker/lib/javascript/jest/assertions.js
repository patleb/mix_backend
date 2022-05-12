module.exports = {
  same: (exp, act) => expect(exp === act).toBe(true),
  different: (exp, act) => expect(exp === act).not.toBe(true),
  equal: (exp, act) => (typeof exp === 'object') ? expect(act).toStrictEqual(exp) : expect(act).toBe(exp),
  not_equal: (exp, act) => (typeof exp === 'object') ? expect(act).not.toStrictEqual(exp) : expect(act).not.toBe(exp),
  null: (act) => expect(act).toBeNull(),
  not_null: (act) => expect(act).not.toBeNull(),
  defined: (act) => expect(act).toBeDefined(),
  undefined: (act) => expect(act).toBeUndefined(),
  called: (act, n = null) => n == null ? expect(act).toBeCalled() : expect(act).toBeCalledTimes(n),
  total: (n) => expect.assertions(n),
}

// =====================================================
// services/menus/menu.service.ts
// =====================================================

import database from "@/lib/prisma/prisma";
import type {
  CreateMenuInput,
  UpdateMenuInput,
  PlanMenuAccessInput,
  UpdatePlanMenuAccessInput,
} from "@/types/schemas/menus/menu.schemas";

// =====================================================
// CREATE MENU
// =====================================================
export async function create(data: CreateMenuInput) {
  // Verify parent menu exists if parentId is provided
  if (data.parentId) {
    const parentMenu = await database.menu.findFirst({
      where: { id: data.parentId, state: "A" },
    });

    if (!parentMenu) {
      throw new Error("PARENT_MENU_NOT_FOUND");
    }
  }

  // Check if name already exists
  const existing = await database.menu.findFirst({
    where: { name: data.name, state: "A" },
  });

  if (existing) {
    throw new Error("MENU_NAME_EXISTS");
  }

  return database.menu.create({
    data: {
      ...data,
      state: "A",
    },
  });
}

// =====================================================
// FIND ALL MENUS (flat list)
// =====================================================
export async function findAll() {
  return database.menu.findMany({
    where: { state: "A" },
    orderBy: [{ sortOrder: "asc" }, { label: "asc" }],
    include: {
      parent: {
        select: {
          id: true,
          name: true,
          label: true,
        },
      },
      _count: {
        select: {
          children: true,
          planAccess: true,
        },
      },
    },
  });
}

// =====================================================
// BUILD HIERARCHICAL MENU TREE
// =====================================================
export async function getMenuTree() {
  const allMenus = await database.menu.findMany({
    where: { state: "A", isActive: true },
    orderBy: [{ sortOrder: "asc" }, { label: "asc" }],
    select: {
      id: true,
      name: true,
      label: true,
      labelKey: true,
      icon: true,
      path: true,
      externalUrl: true,
      target: true,
      parentId: true,
      sortOrder: true,
      isPremium: true,
      badge: true,
      badgeColor: true,
    },
  });

  // Build tree structure
  const menuMap = new Map();
  const rootMenus: any[] = [];

  // First pass: create map of all menus
  allMenus.forEach((menu) => {
    menuMap.set(menu.id, { ...menu, children: [] });
  });

  // Second pass: build tree
  allMenus.forEach((menu) => {
    const menuItem = menuMap.get(menu.id);
    if (menu.parentId) {
      const parent = menuMap.get(menu.parentId);
      if (parent) {
        parent.children.push(menuItem);
      }
    } else {
      rootMenus.push(menuItem);
    }
  });

  return rootMenus;
}

// =====================================================
// GET MENU TREE BY USER PLAN
// =====================================================
export async function getMenuTreeByUser(userId: string) {
  // Get user's active subscription
  const subscription = await database.subscription.findFirst({
    where: {
      userId,
      status: "ACTIVE",
      state: "A",
    },
    include: {
      plan: true,
    },
  });

  if (!subscription) {
    // Return free tier menus only (non-premium)
    return getMenuTree();
  }

  // Get menu access for user's plan
  const planMenuAccess = await database.planMenuAccess.findMany({
    where: {
      planId: subscription.planId,
      state: "A",
      canView: true,
    },
    include: {
      menu: true,
    },
  });

  const accessibleMenuIds = new Set(
    planMenuAccess.map((access) => access.menuId)
  );

  // Get all menus
  const allMenus = await database.menu.findMany({
    where: {
      state: "A",
      isActive: true,
      OR: [
        { isPremium: false }, // Free menus
        { id: { in: Array.from(accessibleMenuIds) } }, // Plan menus
      ],
    },
    orderBy: [{ sortOrder: "asc" }, { label: "asc" }],
    select: {
      id: true,
      name: true,
      label: true,
      labelKey: true,
      icon: true,
      path: true,
      externalUrl: true,
      target: true,
      parentId: true,
      sortOrder: true,
      isPremium: true,
      badge: true,
      badgeColor: true,
    },
  });

  // Build tree structure with permissions
  const menuMap = new Map();
  const rootMenus: any[] = [];

  // Get permissions for each menu
  const permissions = new Map(
    planMenuAccess.map((access) => [
      access.menuId,
      {
        canView: access.canView,
        canCreate: access.canCreate,
        canEdit: access.canEdit,
        canDelete: access.canDelete,
        canExport: access.canExport,
      },
    ])
  );

  // First pass: create map of all menus with permissions
  allMenus.forEach((menu) => {
    menuMap.set(menu.id, {
      ...menu,
      permissions: permissions.get(menu.id) || {
        canView: true,
        canCreate: false,
        canEdit: false,
        canDelete: false,
        canExport: false,
      },
      children: [],
    });
  });

  // Second pass: build tree
  allMenus.forEach((menu) => {
    const menuItem = menuMap.get(menu.id);
    if (menu.parentId) {
      const parent = menuMap.get(menu.parentId);
      if (parent) {
        parent.children.push(menuItem);
      }
    } else {
      rootMenus.push(menuItem);
    }
  });

  return rootMenus;
}

// =====================================================
// FIND BY ID
// =====================================================
export async function findById(id: string) {
  const menu = await database.menu.findFirst({
    where: { id, state: "A" },
    include: {
      parent: {
        select: {
          id: true,
          name: true,
          label: true,
        },
      },
      children: {
        where: { state: "A" },
        orderBy: [{ sortOrder: "asc" }, { label: "asc" }],
        select: {
          id: true,
          name: true,
          label: true,
          icon: true,
          sortOrder: true,
        },
      },
      planAccess: {
        where: { state: "A" },
        include: {
          plan: {
            select: {
              id: true,
              name: true,
              slug: true,
            },
          },
        },
      },
    },
  });

  if (!menu) {
    throw new Error("MENU_NOT_FOUND");
  }

  return menu;
}

// =====================================================
// UPDATE MENU
// =====================================================
export async function update(id: string, data: UpdateMenuInput) {
  const menu = await database.menu.findFirst({
    where: { id, state: "A" },
  });

  if (!menu) {
    throw new Error("MENU_NOT_FOUND");
  }

  // Verify parent menu exists if parentId is provided
  if (data.parentId) {
    const parentMenu = await database.menu.findFirst({
      where: { id: data.parentId, state: "A" },
    });

    if (!parentMenu) {
      throw new Error("PARENT_MENU_NOT_FOUND");
    }

    // Prevent circular reference
    if (data.parentId === id) {
      throw new Error("CIRCULAR_REFERENCE");
    }
  }

  // Check if name already exists (excluding current menu)
  if (data.name) {
    const existing = await database.menu.findFirst({
      where: {
        name: data.name,
        state: "A",
        id: { not: id },
      },
    });

    if (existing) {
      throw new Error("MENU_NAME_EXISTS");
    }
  }

  return database.menu.update({
    where: { id },
    data,
  });
}

// =====================================================
// SOFT DELETE MENU
// =====================================================
export async function softDelete(id: string) {
  const menu = await database.menu.findFirst({
    where: { id, state: "A" },
    include: {
      children: {
        where: { state: "A" },
      },
    },
  });

  if (!menu) {
    throw new Error("MENU_NOT_FOUND");
  }

  // Check if menu has active children
  if (menu.children.length > 0) {
    throw new Error("MENU_HAS_CHILDREN");
  }

  return database.menu.update({
    where: { id },
    data: { state: "I", isActive: false },
  });
}

// =====================================================
// RESTORE MENU
// =====================================================
export async function restore(id: string) {
  const menu = await database.menu.findFirst({
    where: { id, state: "I" },
  });

  if (!menu) {
    throw new Error("MENU_NOT_FOUND");
  }

  return database.menu.update({
    where: { id },
    data: { state: "A", isActive: true },
  });
}

// =====================================================
// ASSIGN PLAN ACCESS TO MENU
// =====================================================
export async function assignPlanAccess(data: PlanMenuAccessInput) {
  const { planId, menuId, ...permissions } = data;

  // Verify menu exists
  const menu = await database.menu.findFirst({
    where: { id: menuId, state: "A" },
  });

  if (!menu) {
    throw new Error("MENU_NOT_FOUND");
  }

  // Verify plan exists
  const plan = await database.plan.findFirst({
    where: { id: planId, state: "A" },
  });

  if (!plan) {
    throw new Error("PLAN_NOT_FOUND");
  }

  // Check if already exists
  const existing = await database.planMenuAccess.findFirst({
    where: { planId, menuId, state: "A" },
  });

  if (existing) {
    // Update existing
    return database.planMenuAccess.update({
      where: { id: existing.id },
      data: permissions,
    });
  }

  // Create new
  return database.planMenuAccess.create({
    data: {
      planId,
      menuId,
      ...permissions,
      state: "A",
    },
  });
}

// =====================================================
// UPDATE PLAN MENU ACCESS
// =====================================================
export async function updatePlanAccess(
  planId: string,
  menuId: string,
  data: UpdatePlanMenuAccessInput
) {
  const access = await database.planMenuAccess.findFirst({
    where: { planId, menuId, state: "A" },
  });

  if (!access) {
    throw new Error("ACCESS_NOT_FOUND");
  }

  return database.planMenuAccess.update({
    where: { id: access.id },
    data,
  });
}

// =====================================================
// REMOVE PLAN ACCESS
// =====================================================
export async function removePlanAccess(planId: string, menuId: string) {
  const access = await database.planMenuAccess.findFirst({
    where: { planId, menuId, state: "A" },
  });

  if (!access) {
    throw new Error("ACCESS_NOT_FOUND");
  }

  return database.planMenuAccess.update({
    where: { id: access.id },
    data: { state: "I" },
  });
}

// =====================================================
// GET PLAN MENU ACCESS
// =====================================================
export async function getPlanAccess(planId: string) {
  return database.planMenuAccess.findMany({
    where: { planId, state: "A" },
    include: {
      menu: {
        select: {
          id: true,
          name: true,
          label: true,
          icon: true,
          path: true,
        },
      },
    },
  });
}
